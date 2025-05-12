---
description: 对任务进行分析评审，确保服务需求
agent: agent
name: spec.analyze
---

专注于任务合理性的评估，**不要执行任何任务**，**只评估任务拆合理性**，**不做需求与设计评估**，只需评估并修正任务拆解结果。

## 工作内容

读取以下文件：
 
- 读取 `/specsai/init.md` 文档，了解该项目的相关内容
- 读取 `/specsai/constitution.md` 文档，了解该项目的约定
- 读取 `/specsai/{BRANCH}/prd.md` 文档以了解当前的需求
- 读取 `/specsai/{BRANCH}/plan.md` 文档以了解当前的设计和技术选型
- 读取 `/specsai/{BRANCH}/task.md` 文档以了解当前的任务规划

评估任务是否符合以上文档的要求，对于不符合规范的任务要求直接修改 `/specsai/{BRANCH}/task.md` 文件，并输出简洁易懂的评估结果给用户，评估结果无需包含在文档中

名词解释：

BRANCH：当前需求对应的 git 分支名称，通常为当前分支，例如：`xxx`。