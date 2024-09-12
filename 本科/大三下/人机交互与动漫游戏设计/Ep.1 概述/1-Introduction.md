# Ep.1

## 一、简介

**游戏软件设计必须具备的知识**：

* 程序设计语言  
  如C/C++，Windows编程模式，各种API函数，SDK工具包的使用
* 数据结构及其相关算法
* 图形图像处理技术  
  3D游戏设计涉及到大量的图形即图像处理技术；2D游戏涉及大量的图像处理技术

**游戏的分类**：

* RPG - 角色扮演游戏  
  侧重故事：历史性的、改编型的、科幻型的故事。
* AVG - 冒险类游戏  
  类似于RPG，强调解密的过程。
* RTS - 即时策略类游戏
* MMORPG - 大型多人在线角色扮演
* SLG - 战棋游戏  
  一类战棋是结合角色扮演和策略游戏，剧情是完整的故事，以关卡推动，每个关卡以策略的战棋来进行
* 体育游戏  
  重点考虑物理学
* 棋牌游戏  
  重点考虑AI

**游戏团队开发人员**：

* 制作人：负责设计、规划游戏整体，开发组长、资源管理、行政管理、向上负责、专案管理
* 执行制作人：重点执行，专案执行、日常管理
* 策划团队：故事设计(Stoty)、脚本设计(Script)、玩法设计(Game Play)、关卡设计(Level)、游戏节奏(Game Tuning)、数值设定(Numerical Setup)、AI设计、音效设定、场景设定(Scene)
* 美术团队：场景(Terrain)、人物(Character)、建模(Model)、材质(Texture)、动作(Motion/Animation)、特效(FX)、用户界面
* 程序设计团队：游戏编程、游戏开发工具（专门给这款游戏开发的工具，如地图编辑器），关卡编辑、场景编辑、特效编辑、脚本编辑、数据导入导出、游戏引擎开发、网络游戏服务器开发
* 销售团队
* 测试团队
* 游戏评论队伍

**开发流程**：

* 创意 - Idea：点子啊、点子……
* 提案 - Proposal：将创意规范化、可行化、现实化
* 制作 - Production
* 整合 - Intergration
* 测试 - Testing
* 出错 - Debug
* 调试 - Tuning

**游戏设计的内容**：

* 游戏类型
* 游戏世界观
* 故事
* 游戏特色(Feature)
* 游戏玩法
* 游戏定位(Game Product Positioning)
* 目标玩家(Target player)
* 市场定位(Marketing positioning/segmentation)
* 风险评估(Risk)
* SWOT分析（优势、缺点、机会、威胁）

**游戏提案的内容**：

* 系统分析(System Analysis)
* 游戏设计文档撰写(GDD)
* 传播媒介文档撰写(Media Design Document)
* 技术设计文档撰写(Technical Design Document)
* 游戏专案建立(Game Project)
* 时间表
* 日程控制
* 危机管理
* 测试计划书
* 团队建立

**课程要求**：

---

Windows的图形处理：

* GDI  
  效率低，会有闪烁的问题（应该是在CPU中处理）
* Direct 2D - 对二维图形的展示  
  直接对接GPU，所以效果很好
* Direct 3D - 对三维图形的展示  
  集成在Windows SDK中

GPU的编程语言：

* GLSL
* HLSL