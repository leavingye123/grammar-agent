# 阶段 7B 验收与交接

开发与真实环境验收日期：2026-09-06；最终测试收尾日期：2026-09-07。角色：接手 Agent B 的 Agent A。本轮开发在原仓库 main 上完成，未提交或推送。

1. **接手代码状态**：HEAD 为 `96ed144`（阶段 7A），初始工作区干净，ahead origin/main 1。交接文档中的 dirty 描述已与实际 Git 状态核对。
2. **保留 7A**：后端与 SQL 零 diff，LessonAttempt / Dashboard / Mastery / XP / Review 全部沿用。V1/V2 未修改。
3. **Design System**：新增 design_tokens、共用卡片、节点、反馈、页面容器、猫咪组件；按钮通过 ThemeData 统一。
4. **绿色 Palette**：自然绿 #187456、深绿 #164D3B、薄荷 #E9F5EE、奶白 #FAFBF7；完整值见设计说明。
5. **Typography**：系统字体，14–16 正文、20–32 标题，宽度约束与自然换行。关键对比度：白字/主绿 5.72:1、正文/奶白 12.25:1、辅助文字/薄荷 4.73:1、错误文字/暖橙 5.22:1。
6. **Cat**：原生矢量 Grammar Cat，普通与庆祝表情，用于登录、问候、解释、结果、空状态、个人中心。
7. **Home**：重新围绕今日任务组织真实目标、继续学习、到期复习、树入口和学习统计。
8. **Grammar Tree 主树**：参考图二的简化树形，七个规划领域；没有真实内容的节点明确不可用，未知课程归入其他语法。
9. **Grammar Branch**：按领域展示知识节点，进入语法点再学习；不假造锁定规则或依赖图。多节点分支另有 Widget Test。
10. **Grammar Point**：概念、规则、可读例句、常见错误、真实前置知识、掌握度与课程路径。
11. **Lesson**：目标、真实标题/描述、最高 XP、学习说明与开始按钮；不编造预计时间和 mastery contribution。
12. **Question**：保留六种输入类型与后端判题，统一题干、进度和选项状态。
13. **Answer Feedback**：正确柔绿、错误暖橙、猫咪鼓励；正确答案与解析均保留，并转换原始答案结构为可读内容。
14. **Lesson Result**：本次成绩、正确率、XP、设备计时、服务端当前 Mastery；仅有真实推荐时显示下一课。
15. **Review**：Grammar Memory、真实到期题数与计划、主动错题复习；复习后刷新相关页面数据。
16. **Profile**：猫咪、账号信息、学习阶段、XP、现有 streak、掌握度、学习概况、退出登录。
17. **Future Features**：预览模块统一“即将推出”，不触发不存在的 API。
18. **Grammar Health**：仅预留，不生成健康百分比或计算公式。
19. **AI Tutor**：仅预留 AI Grammar Coach，无 LLM 或假对话。
20. **Achievements**：Explorer / Keeper / Master 预览，无领取、奖励或假解锁；Plus 无购买。
21. **响应式**：九个主要页面通过 320×568 / 2x 字体检查；长节点标题和未知路径有专门测试。真实设备 1080×2400 API 36 已检查。
22. **动画**：轻量节点/选项容器与进度动画，遵循系统减少动画设置。
23. **API 改动**：无。只有 Flutter 新增 UI 映射、刷新与展示状态。
24. **Backend tests**：`JAVA_HOME=/opt/homebrew/opt/openjdk@21 ./mvnw test`，58 tests，0 failures / errors，BUILD SUCCESS。
25. **Flutter analyze**：No issues found。
26. **Flutter tests**：49 tests 全部通过，包含最后补充的多节点时态分支用例；覆盖原回归与新增页面/路由/布局/刷新/防重复提交。
27. **Android Emulator**：真实端到端用例通过。动态账号注册→登录→Home→主树→基础分支→语法点→Lesson→五题→解析→结算→树状态更新→主动错题复习→Profile→退出。单选故意错一次，结算 4/5、80 分、+8 XP、Mastery 80%；复习后 Profile Mastery 83%、XP 仍为 8。
28. **git diff --check**：通过。
29. **git status**：main ahead origin/main 1（已有的 7A 提交）；本轮 19 个已跟踪文件修改、12 个新增文件未提交。完整路径见下方快照。未执行 commit、push 或 origin 配置修改。
30. **已知限制**：local seed 仅一个语法点/一课/五题，所以时态等领域仍为预览；复习接口无知识点聚合数；正式语言偏好、streak 写入、XP Level 等仍属后续工作。端到端测试仅隔离 TokenStorage 为内存，其余均为真实 API；随机临时测试账号及记录保留在本地开发数据库。
31. **建议给 Agent B**：在确认 UI 后完善英语 A1 课程与领域映射，再按确认的范围推进用户语言偏好和 streak。不要把 UI 推导状态直接扩成数据库真相。

## 实际运行记录

- 后端 58 tests 全部通过。
- 2026-09-07 收尾：Flutter 49 tests 全部通过，flutter analyze 输出 No issues found。上次额度中断时未运行的多节点时态分支用例已通过。
- Android `flutter drive` 完整学习流程通过（1 个业务旅程用例，日志另含 tearDownAll）。
- 正常 `lib/main.dart` 入口 Debug APK 构建成功，已重新安装到 emulator-5554 并启动。
- APK：`mobile/build/app/outputs/flutter-apk/app-debug.apk`。
- 十张真实截图：`mobile/build/7b-evidence/01-home.png` 至 `10-profile.png`。已逐项检查主要页面截图，未见溢出或明显错位。
- 调试用后端监听 18080；PostgreSQL / Redis 均 healthy。没有重建数据库或删除 volume。

完整设计边界与复跑命令见 [阶段 7B 设计说明](stage-7b-design.md)。

## 最终 Git 工作区快照

```text
 M README.md
 M docs/README.md
 M mobile/README.md
 M mobile/lib/core/routing/app_router.dart
 M mobile/lib/core/routing/home_shell.dart
 M mobile/lib/core/theme/app_theme.dart
 M mobile/lib/core/widgets/async_views.dart
 M mobile/lib/features/auth/presentation/auth_controller.dart
 M mobile/lib/features/auth/presentation/auth_screens.dart
 M mobile/lib/features/course/presentation/course_screens.dart
 M mobile/lib/features/home/presentation/home_screen.dart
 M mobile/lib/features/lesson/presentation/lesson_screens.dart
 M mobile/lib/features/lesson/presentation/lesson_session.dart
 M mobile/lib/features/lesson/presentation/question_widgets.dart
 M mobile/lib/features/profile/presentation/profile_screen.dart
 M mobile/lib/features/review/presentation/review_screens.dart
 M mobile/pubspec.lock
 M mobile/pubspec.yaml
 M mobile/test/widget_test.dart
?? docs/stage-7b-acceptance.md
?? docs/stage-7b-design.md
?? mobile/integration_test/stage7b_test.dart
?? mobile/lib/core/network/learning_refresh.dart
?? mobile/lib/core/theme/design_tokens.dart
?? mobile/lib/core/widgets/grammar_cat.dart
?? mobile/lib/core/widgets/grammar_tree_widgets.dart
?? mobile/lib/core/widgets/learning_widgets.dart
?? mobile/lib/core/widgets/option_card.dart
?? mobile/lib/features/course/domain/grammar_tree.dart
?? mobile/test/product_experience_test.dart
?? mobile/test_driver/stage7b_driver.dart
```
