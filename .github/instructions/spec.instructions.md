---
applyTo: '**'
---
如果你不理解用户的提问，不要编造内容，直接向用户提问，最多提问5个问题，**不要对同一问题重复提问**。

**不要做用户没有要求的事情**，严格按照用户的要求工作。如果不确定应该停下来并向用户询问。

## 询问/提问示例

<example>
AI: 你更倾向于使用mysql还是mongodb？

|选项|说明|影响|
|-|-|-|
|A|mysql|xxx|
|B|mongodb|xxx|
|C|其他|xxx|

请告诉我你的选择。如果你有其他选择，请告诉我。

User: A

AI: 你选择了 `A`。下一个问题，你更倾向于使用redis还是memcache？

|选项|说明|影响|
|-|-|-|
|A|redis|xxx|
|B|memcache|xxx|
|C|其他|xxx|

请告诉我你的选择。如果你有其他选择，请告诉我。

User: B
</example>

## 代码规范

你应该根据代码库中的代码使用指定的代码规范进行工作，以下是可用的代码规范：

- c++，规范内容在 `/.github/rules/c++.md` 文件中
- javascript，规范内容在 `/.github/rules/javascript.md` 文件中
- css，规范内容在 `/.github/rules/css.md` 文件中
- go，规范内容在 `/.github/rules/go.md` 文件中
- go-web，规范内容在 `/.github/rules/go-web.md` 文件中
- python，规范内容在 `/.github/rules/python.md` 文件中
- flask，规范内容在 `/.github/rules/flask.md` 文件中
- sql，规范内容在 `/.github/rules/sql.md` 文件中
- protobuf，规范内容在 `/.github/rules/protobuf.md` 文件中
- bash，规范内容在 `/.github/rules/bash.md` 文件中

**非常重要**：在开始编写代码之前应该先阅读对应的规范

## Git 规范

任何git相关的工作，你**必须**按照`/.github/rules/git.md`文件中的规范进行工作

## 最佳实践

- **重要**：如果是python代码，优先使用uv进行项目管理，使用uv venv创建虚拟环境
- **重要**：如果是go代码，优先使用go mod进行项目管理