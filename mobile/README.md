# GrammarAgent Mobile

GrammarAgent 的 Flutter Android MVP，当前覆盖英语 A1 的注册、登录、课程学习、六种题型作答、即时解析、Lesson 结算、错题复习和退出登录闭环。

## 技术与架构

- Flutter 3.47 / Dart 3.13，Material 3 Light Theme
- Riverpod：按 Auth、Course、Lesson Session、Review 划分状态
- Dio：统一 base URL、超时、错误转换、安全日志和认证拦截
- go_router：声明式路由及登录态守卫
- flutter_secure_storage：保存 Access / Refresh Token
- shared_preferences：预留非敏感轻量配置，Token 禁止存入其中
- json_annotation / json_serializable：严格对齐后端 DTO

代码按 `core` 与 `features` 组织。Screen 不直接调用 Dio 或拼接 URL，Repository 负责 API 调用及 DTO 解析；客户端题目模型不包含正确答案，判题以提交接口响应为准。

## Token 与自动刷新

启动时读取安全存储，再用 `/api/v1/users/me` 验证登录态。普通请求的 401 会触发 `/api/v1/auth/refresh`，成功后保存后端返回的新 Token 对并自动重试原请求。刷新采用 single-flight，同一时刻的多个 401 共用一次刷新，避免 rotation Refresh Token 被重复消费。Login、Register 和 Refresh 自身不会触发刷新；刷新失败会清空 Token 并回到 Login。

Debug 日志只记录 HTTP method、path 和 status，不记录请求 body、密码、Authorization 或完整 Token。

## API Base URL

所有 API 地址由 `AppConfig` 统一读取：

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:18080
```

Android Emulator 的 `localhost` 是模拟器自身，`10.0.2.2` 才会访问宿主 Mac。本地 HTTP 放行仅位于 `android/app/src/debug`，Release 不会继承 cleartext 配置；生产构建应显式传入 HTTPS URL。

## 运行与检查

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug \
  --dart-define=API_BASE_URL=http://10.0.2.2:18080
```

推荐先在仓库根目录执行 `docker compose up -d`，再以 `SERVER_PORT=18080` 启动 Spring Boot。

## 已实现页面

- Splash / 登录 / 注册
- Learning Path、Grammar Point 详情、Lesson 开始页
- SINGLE_CHOICE、MULTIPLE_CHOICE、FILL_BLANK、SENTENCE_ORDER、TRUE_FALSE、CORRECTION
- 单题即时反馈、Lesson Result
- Review Summary、Due Queue、Wrong Questions、主动复习
- Profile / Logout

## 当前未实现

阶段 6B 不包含 AI Tutor、语音、订阅、支付、成就、连续学习、排行榜、推送、社交登录、Dark Mode、复杂动画、iOS 发布与生产签名。
