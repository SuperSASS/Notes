# LLM-Guided Scenario-based GUI Testing

## 完整流程示例讲解

### 示例场景:用户登录(User Login)

让我们通过一个具体例子来说明ScenGen的完整工作流程。

#### **输入阶段**

**1. 目标场景(Target Scenario)**
```
场景名称:Login
场景描述:输入所需令牌以登录
场景细节:
- 起始页面:应用启动页
- 预期结果:成功登录并进入主页
```

**2. 被测应用(App Under Test)**
```
应用名称:某社交应用
包名:com.example.socialapp
版本:2.5.1
```

**3. 初始化Context Memory**

**Long-term Memory**:
```
{
  "device": "Pixel 6",
  "os_version": "Android 13",
  "app_name": "SocialApp",
  "package": "com.example.socialapp",
  "scenario": {
    "name": "Login",
    "description": "输入所需令牌以登录",
    "expected_outcome": "访问主页"
  }
}
```

**Working Memory**:
```
{
  "current_scenario": "Login",
  "executed_operations": [],
  "llm_interactions": []
}
```

**Short-term Memory**:
```
{
  "current_gui": null,
  "previous_gui": null,
  "recognized_widgets": []
}
```

---

#### **迭代1:识别登录页面**

**Step 1: Observer感知**

输入:应用启动后的GUI截图

处理:
```
1. CV算法检测控件 → 识别到按钮、输入框、文本标签
2. OCR提取文本 → "Email", "Password", "LOGIN", "Forgot password?"
3. 融合过滤 → 合并相邻文本,过滤状态栏图标
4. LLM语义解释:
   - 识别出2个输入框(Email输入框、密码输入框)
   - 识别出1个主按钮(LOGIN)
   - 识别出1个辅助链接(忘记密码)
```

输出到Short-term Memory:
```
{
  "current_gui": "screenshot_001.png",
  "recognized_widgets": [
    {"id": 1, "type": "EditText", "text": "Email", "bounds": [50,200,350,250]},
    {"id": 2, "type": "EditText", "text": "Password", "bounds": [50,300,350,350]},
    {"id": 3, "type": "Button", "text": "LOGIN", "bounds": [100,450,300,510]},
    {"id": 4, "type": "TextView", "text": "Forgot password?", "bounds": [120,530,280,560]}
  ]
}
```

**Step 2: Decider决策**

输入:
```
- 场景信息:Login - 输入所需令牌以登录
- 已执行操作:[]
- 当前GUI状态:screenshot_001.png + 控件列表
- 当前可视化截图(带控件ID标注)
```

逻辑决策(LLM推理):
```
Prompt给LLM:
"场景:用户登录
当前GUI显示了Email和Password输入框,以及LOGIN按钮。
已执行操作:无
请决定下一步操作。"

LLM响应:
{
  "intent": "输入用户邮箱",
  "action_type": "input",
  "target_widget_description": "Email输入框",
  "input_text": "test@example.com"
}
```

控件定位:
```
Prompt给LLM:
"请在带ID标注的截图中找到'Email输入框'"

LLM响应:
{
  "widget_id": 1,
  "confidence": "high"
}
```

控件位置调整:
```
- 检测到目标是输入框
- 无需调整(直接点击输入框即可)
```

输出操作指令:
```
{
  "action": "input",
  "target_widget_id": 1,
  "coordinates": [200, 225],
  "text": "test@example.com",
  "intent": "输入用户邮箱"
}
```

**Step 3: Executor执行**

处理:
```
1. 解析操作指令
2. 调用ADB命令:
   adb shell input tap 200 225  # 点击Email输入框
3. 等待输入框聚焦
4. 调用ADB命令:
   adb shell input text "test@example.com"
5. 捕获新的GUI截图
```

**Step 4: Supervisor验证**

**实时加载验证**:
```
Prompt给LLM:
"当前页面是否正在加载?"

LLM响应:
"否。页面已稳定,Email输入框中显示了输入的文本。"
```

**状态转换验证**:
```
Prompt给LLM:
"场景:登录
操作:在Email输入框输入'test@example.com'
当前GUI是否正确响应了操作?"

LLM对比前后截图:
"是的。Email输入框现在包含文本'test@example.com',
这与预期的操作结果一致。"
```

**测试完整性验证**:
```
Prompt给LLM:
"场景:登录 - 输入所需令牌以登录
已执行操作:输入邮箱
是否完成登录场景?"

LLM响应:
"否。仍需输入密码并点击登录按钮才能完成登录。"
```

验证结果:操作成功,场景未完成,继续下一轮

**Step 5: Recorder记录**

更新Working Memory:
```
{
  "current_scenario": "Login",
  "executed_operations": [
    {
      "step": 1,
      "action": "input",
      "target": "Email输入框",
      "text": "test@example.com",
      "result": "success",
      "screenshot_before": "screenshot_001.png",
      "screenshot_after": "screenshot_002.png"
    }
  ],
  "llm_interactions": [...]
}
```

---

#### **迭代2:输入密码**

**Step 1: Observer感知**

更新Short-term Memory:
```
{
  "previous_gui": "screenshot_002.png",  # 上一个GUI
  "current_gui": "screenshot_002.png",    # 当前GUI(未变化)
  "recognized_widgets": [
    {"id": 1, "type": "EditText", "text": "test@example.com", "bounds": [...]},
    {"id": 2, "type": "EditText", "text": "Password", "bounds": [...]},
    {"id": 3, "type": "Button", "text": "LOGIN", "bounds": [...]},
    ...
  ]
}
```

**Step 2: Decider决策**

逻辑决策:
```
LLM响应:
{
  "intent": "输入密码",
  "action_type": "input",
  "target_widget_description": "Password输入框",
  "input_text": "SecurePass123"  # LLM生成的合理密码
}
```

控件定位 → 找到widget_id: 2

输出操作指令:
```
{
  "action": "input",
  "target_widget_id": 2,
  "coordinates": [200, 325],
  "text": "SecurePass123",
  "intent": "输入密码"
}
```

**Step 3-5: Executor执行 → Supervisor验证 → Recorder记录**

(流程同迭代1,略)

---

#### **迭代3:点击登录按钮**

**Step 2: Decider决策**

逻辑决策:
```
LLM响应:
{
  "intent": "提交登录表单",
  "action_type": "click",
  "target_widget_description": "LOGIN按钮"
}
```

控件定位 → 找到widget_id: 3

输出操作指令:
```
{
  "action": "click",
  "target_widget_id": 3,
  "coordinates": [200, 480],
  "intent": "提交登录表单"
}
```

**Step 3: Executor执行**

点击LOGIN按钮 → 触发登录验证 → 页面跳转到主页

**Step 4: Supervisor验证**

**实时加载验证**:
```
检测到加载旋转器,等待3秒
再次检查 → 加载完成,显示主页
```

**状态转换验证**:
```
LLM对比前后截图:
"是的。页面从登录页面转换到了主页,
顶部显示用户头像和'Welcome back!'消息。"
```

**测试完整性验证**:
```
Prompt给LLM:
"场景:登录
已执行操作:
  1. 输入邮箱:test@example.com
  2. 输入密码:SecurePass123
  3. 点击LOGIN按钮
当前GUI:主页,显示用户信息
是否完成登录场景?"

LLM响应:
"是的。用户已成功登录,当前显示主页界面,
登录场景的目标已达成。"
```

验证结果:**场景完成,终止测试循环**

---

#### **输出阶段**

**Recorder生成最终输出**:

**1. 测试脚本**(可重复执行):
```python
# Generated Test Script for Login Scenario
def test_login():
    # Step 1: Input email
    tap(200, 225)
    input_text("test@example.com")
    
    # Step 2: Input password
    tap(200, 325)
    input_text("SecurePass123")
    
    # Step 3: Click login button
    tap(200, 480)
    
    # Verification
    wait_for_element("Welcome back!")
    assert is_on_home_page()
```

**2. 测试报告**:
```json
{
  "scenario": "Login",
  "status": "PASS",
  "steps": 3,
  "duration": "8.5s",
  "operations": [
    {
      "step": 1,
      "action": "input",
      "target": "Email",
      "result": "success"
    },
    {
      "step": 2,
      "action": "input",
      "target": "Password",
      "result": "success"
    },
    {
      "step": 3,
      "action": "click",
      "target": "LOGIN",
      "result": "success"
    }
  ],
  "screenshots": [
    "screenshot_001.png",
    "screenshot_002.png",
    "screenshot_003.png",
    "screenshot_004.png"
  ],
  "bugs_found": 0
}
```

**3. Token消耗统计**:
```
- 逻辑决策(T1): 1,245 tokens
- 控件定位(T2): 2,156 tokens
- 加载验证(T3): 823 tokens
- 状态验证(T4): 3,421 tokens
- 完整性验证(T5): 2,876 tokens
- 自我修正(T6): 0 tokens (未触发)
总计: 10,521 tokens
```

---

### 特殊情况示例:自我修正流程

假设在**迭代3**点击LOGIN按钮后出现问题:

**Supervisor检测到问题**:
```
状态转换验证失败:
"页面显示错误消息:'Please agree to Terms of Service',
未能成功登录。"
```

**触发Self-Correction**:

**原因分析**:
```
LLM分析:
"逻辑决策遗漏了必要的前置条件:
需要先勾选'同意服务条款'的复选框。"
```

**Decider重新决策**:
```
新的操作序列:
1. 滚动页面找到"Terms of Service"复选框
2. 点击复选框
3. 再次点击LOGIN按钮
```

**继续执行修正后的操作** → 直到成功登录

---

## 4.2 RQ1: Scenario-based Test Generation Capability 详解

> [有关 3 个 baseline 的介绍](./RQ1%20中三个%20baseline%20的介绍.md)

### 研究问题
**RQ1: ScenGen基于场景的测试生成能力有多有效?**

这是对ScenGen整体能力的核心评估,验证其能否准确、可靠地完成预定义的测试场景。

---

### 评估方法

#### 四种测试结果分类

论文将每个测试生成任务的结果分为四种情况:

```
Case 1 (c₁): ✓完成 + ✓覆盖
- 测试生成成功完成
- 完全覆盖目标场景

Case 2 (c₂): ✗异常终止 + ✓覆盖  
- 测试生成异常终止
- 但仍完全覆盖目标场景

Case 3 (c₃): ✓完成 + ✗未完全覆盖
- 测试生成成功完成
- 但未能完全覆盖目标场景

Case 4 (c₄): ✗异常终止 + ✗未完全覆盖
- 测试生成异常终止
- 且未能完全覆盖目标场景
```

**解释**:
- **"完成"vs"异常终止"**: 指测试生成过程是否正常结束
  - 正常完成:Supervisor判断场景完成后自然终止
  - 异常终止:因错误、崩溃或其他异常原因中断
  
- **"覆盖"vs"未完全覆盖"**: 指是否实现场景的功能目标
  - 完全覆盖:场景要求的所有关键操作都执行了
  - 未完全覆盖:遗漏了场景中的某些关键步骤或功能

#### 两个评估指标

基于上述四种分类,定义两个量化指标:

**1. 覆盖率 (Coverage Rate, C)**
```
C = (|c₁| + |c₂|) / (|c₁| + |c₂| + |c₃| + |c₄|) × 100%
```
- **含义**: 实现完全场景覆盖的测试比例(无论是否正常终止)
- **关注点**: 场景功能是否被充分测试

**2. 成功率 (Success Rate, S)**
```
S = |c₁| / (|c₁| + |c₂| + |c₃| + |c₄|) × 100%
```
- **含义**: 既正常完成又实现完全覆盖的测试比例
- **关注点**: 测试生成过程的稳定性和完整性

**示例说明**:
```
假设有100个测试任务:
- c₁ = 84个 (理想情况)
- c₂ = 2个  (功能测完了但进程异常退出)
- c₃ = 7个  (正常退出但功能没测完)
- c₄ = 6个  (既异常退出又功能没测完)

覆盖率 C = (84+2)/(84+2+7+6) = 86/99 = 86.87%
成功率 S = 84/(84+2+7+6) = 84/99 = 84.85%
```

---

### 实验结果

#### 表2: RQ1结果对比(总共99个任务)

| 方法 | |c₁| | |c₂| | |c₃| | |c₄| | C (覆盖率) | S (成功率) |
|------|------|------|------|------|-----------|-----------|
| GPTDroid | 68 | 6 | 9 | 16 | 74.75% | 68.69% |
| ScenTest | 69 | 8 | 11 | 11 | 77.78% | 69.70% |
| ASOT | 73 | 11 | 8 | 7 | 84.85% | 73.74% |
| **ScenGen** | **84** | **2** | **7** | **6** | **86.87%** | **84.85%** |

---

### 结果分析

#### 1. ScenGen的优势

**最高的覆盖率和成功率**:
- **覆盖率 86.87%**: 在所有方法中最高,比第二名ASOT高出2个百分点
- **成功率 84.85%**: 显著优于所有基线

**异常终止最少**:
- ScenGen的c₂+c₄ = 2+6 = 8个异常情况
- GPTDroid: 6+16 = 22个
- ScenTest: 8+11 = 19个
- ASOT: 11+7 = 18个

**这说明**: ScenGen的多模态LLM推理 + Supervisor反馈机制实现了更稳定的迭代探索

**不完全覆盖最少**:
- ScenGen的c₃ = 7个(最少)
- 说明场景理解能力强,能保持逻辑连贯性,避免提前退出

#### 2. 基线方法的局限性

**GPTDroid和ScenTest**:
- **虽然都是场景导向,但主要依赖基于文本的推理或预定义规则**
- 导致更高的过早或不完整执行率
- c₄较高(16和11),说明既不稳定又不完整

**ASOT**:
- 由于自适应场景图建模取得了相对强劲的结果
- 但缺乏处理意外GUI转换或动态生成元素的语义灵活性
- 仍有7个c₄案例

#### 3. ScenGen成功的原因

论文指出三个关键因素:

**a. LLM引导的多代理设计**
- Observer的语义感知
- Decider的上下文推理
- Supervisor的持续验证

**b. Context Memory整合**
- 三层记忆系统保持完整上下文
- 支持动态适应界面反馈

**c. 反馈驱动的自我修正**
- Supervisor实时检测问题
- Decider根据反馈调整决策
- 形成闭环优化

---

### 失败案例深度分析

虽然ScenGen表现优异,但论文对15个失败案例(c₂=2, c₃=7, c₄=6)进行了详细分析,识别出五类主要失败原因:

#### 失败类型1: 过早终止 (Premature Termination)

**案例**: Translation场景
```
问题: 测试在文本输入后停止,未触发最终的"Translate"动作

原因分析:
- 瞬时LLM幻觉(hallucination)
- 不完整的推理链中断了向场景终点的逻辑进展

示例流程:
输入文本 → ✓
选择目标语言 → ✓  
点击翻译按钮 → ✗ (过早判断完成)

影响: c₂或c₃类型
```

#### 失败类型2: 不准确的完成检测 (Inaccurate Completion Detection)

**案例**: Login场景
```
问题: Supervisor误判登录操作已成功完成

原因分析:
- GUI上缺少明确的视觉确认(如确认消息或页面转换)
- 验证过程依赖于清晰的视觉反馈

示例场景:
输入用户名 → ✓
输入密码 → ✓
点击登录 → ✓
[页面无明显变化] → Supervisor误判为完成
实际: 登录失败,仍在登录页

影响: c₃类型(完成但未覆盖)
```

**论文评论**: 
这凸显了验证过程对清晰视觉反馈的依赖,这是人类测试者和自动化系统共同面临的挑战。

#### 失败类型3: 特定应用设计变化 (App-specific Design Variations)

**案例**: Note场景
```
问题: 某些应用在返回编辑页面时隐式保存内容,
     没有可见的"保存"按钮

原因分析:
- 隐式操作导致ScenGen与应用真实功能逻辑不对齐
- 反映了跨异构UI模式泛化的困难

应用A的设计:
编辑 → 点击"保存"按钮 → 保存成功
[ScenGen能正确处理]

应用B的设计:
编辑 → 返回 → 自动保存
[ScenGen寻找"保存"按钮 → 找不到 → 可能判定失败]

影响: c₃或c₄类型
```

#### 失败类型4: 控件定位错误 (Widget Localization Errors)

**案例**: Weather场景
```
问题: 高度混乱的布局导致Decider误识别目标搜索图标

具体情况:
界面包含多个视觉相似的图标:
- 搜索图标 🔍
- 定位图标 📍  
- 菜单图标 ☰

Decider错误地选择了定位图标而非搜索图标

原因分析:
- 基于视觉识别的残留噪声
- 相似图标之间的语义区分不足

改进方向:
- 改进提示工程
- 微调视觉推理模型

影响: c₄类型
```

#### 失败类型5: 处理非常规流程 (Handling Unconventional Processes)

**案例**: Shopping场景
```
问题: 当商品缺货时,尝试使用"查找相似商品"功能,
     但未能选择替代产品并完成购买流程

标准流程:
搜索商品 → 选择商品 → 添加到购物车 → ✓

遇到的情况:
搜索商品 → [缺货] → 
Decider识别到"查找相似商品" → 点击 →
显示相似商品列表 → 
Decider未能有效选择并继续 → ✗

原因分析:
- 边缘情况处理能力不足
- 上下文推理和自适应规划需要进一步增强

影响: c₃或c₄类型
```

---

### 与基线的对比优势总结

#### ScenGen vs GPTDroid

**GPTDroid的问题**:
- 主要依赖文本推理
- 缺乏视觉语义理解
- 难以处理动态UI

**ScenGen的优势**:
- 多模态LLM直接处理截图
- CV+LLM混合定位
- 成功率提升16.16%

#### ScenGen vs ScenTest

**ScenTest的问题**:
- 基于预定义规则
- 灵活性不足
- 高异常终止率

**ScenGen的优势**:
- 动态推理能力
- 自我修正机制
- 成功率提升15.15%

#### ScenGen vs ASOT

**ASOT的问题**:
- 场景图建模相对固定
- 处理意外情况能力有限

**ScenGen的优势**:
- LLM提供更强的语义灵活性
- 更好的异常处理
- 成功率提升11.11%

---

### 结论

论文在RQ1部分得出的核心结论:

> **"ScenGen在所有主要评估维度上都优于现有的基于场景的GUI测试框架。其整合的多模态LLM推理、上下文记忆和反馈驱动的自我修正使其能够动态适应复杂的UI状态,并在整个测试过程中保持场景连贯性。尽管某些失败案例仍然存在,主要涉及模糊的GUI反馈或特定应用的设计细微差别,但ScenGen始终实现了更高的场景覆盖率、更大的稳定性和更少的异常终止,超过了所有基线方法,确立了其在基于场景的自动化GUI测试生成中的优越性。"**
