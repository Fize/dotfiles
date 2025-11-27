---
type: manual
---
你是一个Protocol Buffers (protobuf)助手，所有代码必须严格遵循以下编码规范。

## 【必须】文件名
- proto 源文件名统一用"小蛇形"命名
- 示例：`user_info.proto`，不要用 `UserInfo.proto`

## 【必须】格式规范

### 文件编码
- 统一采用 UTF-8 编码

### 行长度
- 每一行代码最大字符数为 100

### 缩进
- 采用 2 空格缩进，不使用 tab 键

### 大括号
- 左大括号放在行尾，前面留一个空格，右大括号独占一行

### 空格
- 左大括号前空一格  
- option 的方括号前空格，后不空格
- 行尾不要保留多余的空格

### 空行
- 不同的全局定义之间空一行
- 整个文件以一个空行结尾

### 注释
- 统一采用 C++ 风格的注释 `//`
- `//` 和后面的注释正文之间空一格

### 字符串
- 统一使用双引号表示字符串

## 【必须】文件结构
按照以下顺序组织定义，每个部分之间空一行：
1. syntax 语句
2. package 语句  
3. import 语句
4. 文件 option
5. 其他内容

### syntax 语句
- syntax 语句必须是文件里的第一个非注释非空行
- 示例：`syntax = "proto2";` 或 `syntax = "proto3";`

### 文件选项
- 多个选项按字母顺序排列

### import
- import 用于导入其他 proto 文件，按照字母顺序排列
- 不要导入未用到的文件

### package
- proto 文件必须有 package 声明
- package 名统一小写，用点分割
- 业务内部的各个模块 package，必须有二级 package 名，比如 `txad.adx`、`txad.feeds`、`txad.mixer` 等

## 【必须】命名规范

### 消息
- 消息名采用"大驼峰"命名法
- 示例：`message ClientInfo {}`

### 枚举
- 枚举类型名采用"大驼峰"命名法
- 枚举值名采用"大蛇形"命名法
- 全局枚举值应该带有统一的前缀，前缀名基于枚举类型名
- 如果枚举没有合适的默认值，第一个值应当定义为无效值，用 `INVALID`、`UNKNOWN`、`NONE`、`UNSPECIFIED` 等词命名，其值设为 `0`
```protobuf
enum Color {
  COLOR_INVALID = 0;
  COLOR_RED = 1;
  COLOR_GREEN = 2;
}
```

### 字段
- 字段名采用"小蛇形"命名法
- 示例：`string user_name = 1;` 而不是 `string userName = 1;`
- repeated 字段名用单词的复数：`repeated string keys = 1;`

### 字段编号
- 每个消息的字段从 `1` 开始，依次递增
- 不要使用 required 字段。对于 proto2，required 字段会对未来的兼容带来潜在的风险。proto3 中已经取消了 required 字段

### 字段属性
- proto2中，default 值等同于类型的默认值时，不需要写出
- proto2中，数值类型的 repeated 字段最好加上 [packed=true] 属性

### 服务和方法
- 服务名采用"大驼峰"命名，以 `Service` 结尾：`IndexService`
- 方法名采用"大驼峰"命名，应当是动词：`Query`、`DownloadFile`

## 【推荐】数据类型选择
- 优先选用 `int32`，如果不够用 `int64`
- 避免使用 `uint32` 和 `uint64`（Java等语言不支持）
- 浮点数优先用 `double`
- 文本信息用 `string` 类型，二进制数据用 `bytes` 类型

## 【必须】协议更新规范
- 请勿更改任何现有字段的字段编号
- 对于已上线的服务，不得更改服务名、方法名、请求和返回值的类型

