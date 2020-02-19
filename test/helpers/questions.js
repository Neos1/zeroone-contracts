module.exports = { 
  questions : [{
    groupId: 0,
    name: "Добавить Вопрос",
    description: "Добавление нового вопроса",
    timeLimit: 10 * 3600,
    methodSelector: "0x9c88d333",
    paramNames: [
      "GroupId",
      "Name",
      "Caption",
      "Time",
      "MethodSelector",
      "Formula",
      "paramNames",
      "paramTypes"
    ],
    paramTypes: [
      "uint",
      "string",
      "string",
      "uint",
      "bytes4",
      "string",
      "string[]",
      "string[]"
    ],
  },
  {
    groupId: 0,
    name: "Подключить группу пользователей",
    description: "Подключить новую группу пользователей для участия в голосованиях",
    timeLimit: 10 * 3600,
    methodSelector: "0x70b0e2c8",
    paramNames: [
      "Name",
      "Address",
      "Type",
    ],
    paramTypes: [
      "string",
      "address",
      "string"
    ],
  },
  {
    groupId: 0,
    name: "Добавить группу вопросов",
    description: "Добавить новую группу вопросов",
    timeLimit: 10 * 3600,
    methodSelector: "0xb9253b2b",
    paramNames: [
      "Name"
    ],
    paramTypes: [
      "string"
    ],
  },
  {
    groupId: 0,
    name: "Установить администратора группы",
    description: "Установка администратора в группе кастомных токенов",
    timeLimit: 10 * 3600,
    methodSelector: "0x9c88d333",
    paramNames: [
      "Group Address",
      "New Admin Address"
    ],
    paramTypes: [
      "address",
      "address"
    ],
  }]
}