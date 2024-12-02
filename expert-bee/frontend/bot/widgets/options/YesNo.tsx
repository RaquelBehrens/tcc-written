import React from "react";
import { styled } from "styled-components";

const StyledButton = styled.button`
  padding: 0.5rem 1rem;
  border: 1px solid rgb(var(--primary-color));
  color: rgb(var(--primary-color));
  border-radius: 5rem;
  transition: 0.15s;
  &:active {
    transform: scale(0.95);
  }
`;

const GotIt: React.FC<any> = (props) => {
  const options = [
    {
      name: "Sim",
      handler: props.actionProvider.handleYes,
      id: 1,
    },
    {
      name: "Não",
      handler: props.actionProvider.handleNo,
      id: 2,
    },
  ];
  return (
    <div className="options-container">
      {options.map((option) => {
        return (
          <StyledButton
            key={option.id}
            className="option-button"
            onClick={option.handler}
          >
            {option.name}
          </StyledButton>
        );
      })}
    </div>
  );
};

export default GotIt;
