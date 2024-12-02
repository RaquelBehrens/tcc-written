:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_session)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_cors)).

% Define o handler para receber as requisições HTTP
:- http_handler(root(server), handle_post_request, [method(post)]).
:- http_handler(root(questions), handle_get_questions, [method(get)]).
:- http_handler(root(.), handle_options, [method(options)]).

get_frontend_url(URL) :-
    getenv('VITE_FRONTEND_URL', URL).

handle_options(Request) :-
    get_frontend_url(FrontendUrl),

    cors_enable(Request, [methods([post, get, options])]),
    format('Access-Control-Allow-Origin: ~w~n', [FrontendUrl]),
    format('Access-Control-Allow-Credentials: true~n'),
    format('Content-Length: 0~n~n').

% Inicialização do servidor na porta 6357
:- initialization main.

main :-
    server(6358).

server(Port) :-
    http_server(http_dispatch, [port(Port), allow_cors(true)]).

% Manipulador de requisições POST
handle_post_request(Request) :-
    member(method(post), Request), !,
    
    % Garante que a sessão está ativa para o cliente
    http_session_id(_SessionID),

    % Lê os dados da requisição
    http_read_data(Request, Data, [encoding(utf8)]),

    get_frontend_url(FrontendUrl),

    % Definindo os headers para permitir CORS
    format('Access-Control-Allow-Origin: ~w~n', [FrontendUrl]),
    format('Access-Control-Allow-Credentials: true~n'),
    format('Content-Type: application/json; charset=UTF-8'),
    cors_enable(Request, [methods([post])]),

    (   % Caso seja a primeira requisição da questão
        member(questionNumber=QN, Data) 
    ->  % Inicializa a sessão e a questão
        http_session_retractall(questionNumber(_)),
        http_session_retractall(answers("Answers", _)),
        http_session_assert(answers("Answers", [])),
        
        http_session_assert(questionNumber(QN)),
        start_question(QN, FirstQuestion),

        reply_json_dict(FirstQuestion)

    ;   % Caso receba respostas subsequentes
        member(answer=Answer, Data),
        
        % Garante que a sessão tenha a variável questionNumber
        ( http_session_data(questionNumber(QN)) ->
            continue_question(QN, Answer, NextQuestionOrResult),
            reply_json_dict(NextQuestionOrResult)
        ;   % Erro caso a sessão não tenha um questionNumber
            reply_json_dict(_{error: "Número da questão não encontrado na sessão"})
        )
    ).

% Carrega o arquivo de questão com base no número e executa a questão correspondente
start_question(QuestionNumber, FirstQuestion) :-
    atom_concat('questao_', QuestionNumber, FileName),
    atom_concat(FileName, '.pl', FilePath),

    % Verifica se o arquivo existe antes de tentar carregá-lo
    (   exists_file(FilePath)
    ->  % Carrega dinamicamente o arquivo da questão
        abolish(questao/3),
        abolish(diagnostico/3),

        ensure_loaded(FilePath),
        atom_number(QuestionNumber, QN),        
        
        % Executa o predicado correspondente à questão com o número recebido
        (   catch(call(questao(QN, [], FirstQuestionResult)), E2,
                (FirstQuestion = _{error: "Erro ao processar a questão: " + E2}))
        ),
        (   var(FirstQuestionResult) % Verifica se ocorreu erro na chamada
        ->  FirstQuestion = _{error: "Erro desconhecido"}
        ;   FirstQuestion = _{question: FirstQuestionResult}
        )
    ;   FirstQuestion = _{error: "Questão não encontrada."}
    ).

% Processa a resposta recebida e decide a próxima pergunta ou resultado final
continue_question(QuestionNumber, Answer, Response) :-
    (   string(Answer) -> AW = Answer
    ;   atom(Answer) -> atom_string(Answer, AW)
    ;   term_string(Answer, AW)
    ),
    atom_number(QuestionNumber, QN), 

    % Salva a resposta na sessão
    http_session_data(answers("Answers", AnswerList)),
    append(AnswerList, [AW], UpdatedAnswers),
    http_session_retractall(answers("Answers", _)),
    http_session_assert(answers("Answers", UpdatedAnswers)),

    % Chama a questão correspondente com a lista atualizada de respostas
    (   questao(QN, UpdatedAnswers, NextQuestion)
    ->  Response = _{question: NextQuestion}
    ;   (   diagnostico(QN, UpdatedAnswers, Result)
        ->  true
        ;   Result = "Sem conclusão final."
        ),
        Response = _{result: Result}
    ).


% Manipulador de requisições GET
handle_get_questions(Request) :-
    cors_enable(Request, [methods([get])]),

    get_frontend_url(FrontendUrl),

    % Definindo os headers para permitir CORS
    format('Access-Control-Allow-Origin: ~w~n', [FrontendUrl]),
    format('Access-Control-Allow-Credentials: true~n'),
    format('Content-Type: application/json; charset=UTF-8'),

    working_directory(CWD, CWD),
    find_question_files(CWD, QuestionNumbers),
    reply_json(QuestionNumbers).

% Encontrar arquivos de questão no diretório e extrair os números
find_question_files(Directory, QuestionNumbers) :-
    directory_files(Directory, Files), % Listar todos os arquivos no diretório
    include(is_question_file, Files, QuestionFiles), % Filtrar arquivos no formato correto
    maplist(extract_question_number, QuestionFiles, QuestionNumbers).

% Verifica se o arquivo está no formato 'questao_{numero}.pl'
is_question_file(File) :-
    sub_string(File, _, _, _, 'questao_'),
    sub_string(File, _, 3, 0, '.pl').

% Extrair o número da questão a partir do nome do arquivo
extract_question_number(File, Number) :-
    sub_string(File, Start, Length, _, 'questao_'),
    AfterPrefix is Start + Length,
    sub_string(File, AfterPrefix, _, 3, NumberString), % Extrai o número antes do '.pl'
    atom_number(NumberString, Number). % Converte para número.