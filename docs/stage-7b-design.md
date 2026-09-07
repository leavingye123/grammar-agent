# 阶段 7B：品牌与学习体验

## 接手基线与范围

基线为 `96ed144`（stage 7 A completed），接手时工作区干净，本地领先 origin/main 一个提交。
7A 的 LessonAttempt、Dashboard、状态化 Learning Path、Mastery、XP 结算和复习逻辑继续使用。
本轮只修改 Flutter 与文档；没有修改后端、Flyway V1/V2，也没有新增 migration。

视觉采用参考图一的绿色品牌与猫咪伙伴，学习地图采用参考图二的两级语法树。
依据交接文档，实际实现去掉复杂森林、岛屿、荧光光晕和固定假进度，以浅色背景、树干、叶片、圆角节点为主。
猫咪和树枝由 Flutter CustomPainter 绘制，界面文字、按钮与进度仍为原生可访问组件，不是整张图片上的热区。

## 设计系统

| Token | 值 / 用途 |
| --- | --- |
| Primary | #187456，主要按钮、交互状态 |
| Deep Green | #164D3B，标题、熟练节点 |
| Soft Green | #DCEED9，成长状态 |
| Mint | #E9F5EE，正确反馈、轻量强调 |
| Surface Green | #F1F7F0，预览与辅助区 |
| Background | #FAFBF7，奶白背景 |
| Warm Yellow | #F3CC68，预留 XP / 成就强调 |
| Soft Orange / Orange | #FFF0DF / #985322，温和错误反馈 |
| Ink / Secondary | #20372F / #5C7067，主要与辅助文字 |
| Border | #DDE7DF，卡片边界 |

排版采用系统字体（含中文回退），正文 14–16、标题 20–32，增加行高；不依赖在线字体。
间距统一 4/8/12/16/24/32，圆角 12/24/32。容器最大宽度 720，内容可滚动。
按钮沿用 Material 的 FilledButton / OutlinedButton，由主题统一配置，避免只转发参数的包装类。
复用 GrammarCard、ProgressCard、StatCard / StatGrid、GrammarNode、TreeRow、LessonCard、OptionCard、
FeedbackPanel、LoadingView / ErrorView / EmptyView、GrammarCat / CatMessage、SectionHeader、FutureFeature。
轻动画使用 AnimatedContainer / TweenAnimationBuilder，遵循系统 disableAnimations。

## 信息架构与数据

- 底部四项：首页、学习、复习、我的。保留原 GoRouter 与认证守卫。
- 首页：今日 XP 目标、后端推荐的继续学习、到期错题、语法树入口、真实 Mastery / XP / 正确率。
- 主树：七个规划领域；选择领域进入二级知识树，再进入语法点与 Lesson。
- 分支按已有课程顺序展示，树枝只表达主题归属，不伪装成数据库中的依赖边或解锁规则。
- 真实前置语法使用 GrammarPoint Detail 的 prerequisites，支持点击查看。
- 主树阶段列表来自 API 的 levels；语言名称来自响应，不在组件中写死 English A1。
  当前仓库的课程 Repository 仍按现有范围请求英语；暂未新增用户语言偏好或语言切换 API。
- 领域映射为 `language:grammarPointCode` 的显式前端编辑配置；未知代码进入“其他语法”，内容不会被丢弃。
  新增课程时需要补齐映射，不能按标题关键词猜测领域。
- 当前 local seed 仅有 EN_A1_BE_001 / 一个 Lesson / 五道题。只有基础语法领域有真实课程。
  时态等领域显示“即将推出”，不可点击；二级树支持多节点，由 Widget Test 验证，不为截图制造课程。
- 主树统计“已完成语法点 / 当前阶段全部语法点”；分支从同一 API 汇总。课程完成与掌握度是不同概念。

## 成长状态映射（仅 UI）

| 条件 | 显示 |
| --- | --- |
| NOT_STARTED 且 mastery=0 | 未探索，灰绿小芽 |
| IN_PROGRESS 或 mastery>0 | 正在学习，浅绿 |
| COMPLETED 且 mastery<90 | 继续巩固，绿色 |
| COMPLETED 且 mastery>=90 | 熟练掌握，深绿叶片 |
| DUE_FOR_REVIEW | 只预留暖橙视觉，不推导或伪造到期语法状态 |

90 是可调整的 UI 阈值，不是新增业务规则，不会写回服务器。
已完成的语法点仍可进入练习；没有 LOCKED，灰绿不表示被锁定。

## 课程与反馈

语法点重新组织为核心概念、规则、可读例句、常见错误、真实前置知识和 Lesson。
Lesson 展示真实标题、描述、最高可得 XP 与学习方式；API 无预计时长，不伪造固定分钟数或 mastery contribution。
保留六题型和服务端判题。选项显示选中状态；正确用柔绿、错误用暖橙，均保留正确答案与解析。
正确答案将服务端 optionId / optionIds、answers、acceptedAnswers、tokens、value 转为人类可读文字。

结果页显示本次正确数、Score、正确率、XP、设备端记录的本次页面用时（包含阅读与等待），以及重新读取的当前 Mastery。
没有假造 before/after mastery；下一课继续使用 Dashboard 推荐。缺失推荐或读取失败均有明确处理。
无有效结算 extra 的结果路由回到对应 Lesson，避免直接打开链接时崩溃。

服务器确认答题 / 结算 / 复习后刷新 Dashboard、myLearningPath 和复习读模型。
登录、退出也清理这些缓存，避免跨账号残留；结算按钮在请求中禁用，阻止重复点击发送多个结算请求。

## 复习、个人中心与预览

复习定位为 Grammar Memory，展示真实错题数和到期时间。API 无语法点聚合数，不把题数伪装成知识点数。
个人中心展示真实账号信息、学习阶段、XP、Mastery、课程进度与现有 streak 值。
学习阶段（例如 A1）不冒充 XP 等级；当前 streak 写入机制仍属于 7A 已知技术债。

Grammar Health、AI Grammar Coach、混合挑战、每日表达、学习笔记、成就和 Plus 均为静态“即将推出”预览。
它们没有支付按钮、假奖励、假 AI 对话或不存在的 API 调用。

## 可重复验收

```bash
# backend/，Java 21
./mvnw test

# mobile/
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:18080

# 启动本地 PostgreSQL、Redis、Spring Boot（18080）和 API 36 模拟器后
flutter drive --driver=test_driver/stage7b_driver.dart \
  --target=integration_test/stage7b_test.dart -d emulator-5554 \
  --dart-define=API_BASE_URL=http://10.0.2.2:18080
```

集成测试使用真实后端、动态生成的临时账号与随机密码。只将 TokenStorage 隔离为内存，避免影响模拟器原有登录；
不替换业务 Repository 或 API 响应。临时账号与学习记录会留在本地开发数据库中。
截图输出到 mobile/build/7b-evidence/（不提交 Git）。日常运行仍使用 lib/main.dart 与安全存储。

Widget Test 覆盖主要页面、导航、错误 / 空状态、长标题、320×568 / 2x 字体、节点刷新、答案可读性和重复结算保护。
实际执行结果见 stage-7b-acceptance.md。

## 留给下一轮

优先完善课程内容与领域映射，使更多真实知识能填充主树与二级树，再考虑正式语言偏好和完整 streak。
Grammar Health 算法、AI、会员支付、成就发放、间隔复习调度仍未实现，不属于本轮。
