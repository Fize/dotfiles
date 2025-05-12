---
description: 对需求进行澄清，确保需求文档的完整性
agent: agent
name: spec.clarify
---

专注于需求的澄清，**不做具体的实现**。

## 工作内容

### 读取文件
 
-. 读取 `/specsai/init.md` 文档，了解该项目的相关内容

### 需求澄清

- 仔细阅读 `/specsai/{BRANCH}/prd.md` 文档以了解当前的需求，详细评估需要澄清的内容
- 向用户提问要求用户进行澄清相关的问题或影响。
- 如果没有需要澄清的内容，告知用户需求已经清晰，请执行下一步 '/spec.plan' 命令
- 将澄清后的需求写入 `/specsai/{BRANCH}/prd.md` 文档

名词解释：

BRANCH：当前需求对应的 git 分支名称，通常为当前分支，例如：`xxx`。