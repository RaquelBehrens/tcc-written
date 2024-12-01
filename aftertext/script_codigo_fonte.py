import os

# Diretório do código-fonte
codigo_dir = "/home/raquel/Documentos/tcc/expert-bee/"
saida_latex = "codigo_listado.tex"

# Nome do arquivo LaTeX onde os códigos serão incluídos
arquivo_saida = "code_files.tex"

with open(arquivo_saida, "w") as f:
    for root, _, files in os.walk(codigo_dir):
        for file in files:
            caminho_completo = os.path.join(root, file)
            caminho_relativo = os.path.relpath(caminho_completo, codigo_dir)
            f.write(f"\\subsection*{{{caminho_relativo}}}\n")
            f.write(f"\\lstinputlisting{{{caminho_completo}}}\n\n")

print(f"Arquivo '{arquivo_saida}' gerado com sucesso!")