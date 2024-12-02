import { useState } from "react";
import Chatbot from "react-chatbot-kit";
import "react-chatbot-kit/build/main.css";
import { styled } from "styled-components";
import config from "../../bot/config";
import ActionProvider from "../../bot/ActionProvider";
import MessageParser from "../../bot/MessageParser";
// import { AppDispatch, useAppSelector } from "../../redux/store";
// import { useDispatch } from "react-redux";
// import { decrementCount } from "../../redux/features/messages-slice";
// import { useNavigate } from "react-router-dom";

const StyledChat = styled.div`
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 95vh;


  .react-chatbot-kit-chat-container {
    width: 35rem !important;
    height: 40rem;
  }
  .react-chatbot-kit-chat-input-container {
    width: 34.9rem !important;
  }

  .react-chatbot-kit-chat-message-container {
    height: 35.5rem;
  }

  .react-chatbot-kit-chat-bot-message-container {
    & > img {
      margin-right: 0.8rem;
    }
  }

  .react-chatbot-kit-user-chat-message-container {
    & > img {
      margin-left: 0.8rem;
    }
  }

  & .intro {
    height: 9rem;
    text-align: center;
    & > h1 {
      font-size: 3.5rem;
    }
    & > button {
      color:rgb(var(--dark-color));
      margin-top: 1rem;
      padding: 0.75rem 2rem;
      font-size: 1.5rem;
      border-radius: 5rem;
      border: 1px solid rgb(var(--dark-color));
      transition: 0.15s;
      &:active {
        transform: scale(0.95);
        border-color: rgb(var(--tertiary-color));
      }
    }
  }
  & > div:not(.intro) {
    & .react-chatbot-kit-chat-inner-container {
      border: 1px solid rgb(var(--dark-color) / 0.25);
      border-radius: 1rem;
      overflow: hidden;
      width: 35rem;
      height: 40rem;
      & .react-chatbot-kit-chat-bot-message {
        width: 20rem;
        margin-left: 0 !important;
        border-bottom-left-radius: 0;
        & .react-chatbot-kit-chat-bot-message-arrow {
          border-width: 0;
        }
      }
    }
  }
`;

const Chat = () => {
  const [isOpened, setIsOpened] = useState<boolean>(false)
  /* Exemplo de uso do messages-slice, caso precise no futuro
  const navigate = useNavigate();
  const count = useAppSelector((state) => state.messageReducer.count);
  const dispatch = useDispatch<AppDispatch>();
  useEffect(() => {
    const interval = setInterval(() => {
      if (count > 0) {
        dispatch(decrementCount());
      } else if (count === 0) {
        navigate("/success");
      }
    }, 1000);
    return () => {
      clearInterval(interval);
    };
  }, [count, dispatch, navigate]);
  */
  return (
    <StyledChat>
      <div className="intro">
        <h2>Aqui você pode tirar dúvidas sobre algumas questões do Beecrowd!</h2>
        <button onClick={() => setIsOpened((prev) => !prev)}>
          Comece agora!
        </button>
      </div>
      {isOpened && (
        <Chatbot
          config={config}
          messageParser={MessageParser}
          actionProvider={ActionProvider}
        />
      )}
    </StyledChat>
  );
};

export default Chat;
