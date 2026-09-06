# GrammarAgent

GrammarAgent 是一款专注于外语语法学习与练习的智能学习产品。产品将通过关卡、进度、XP、连续学习天数和即时反馈，帮助学习者沿着由易到难的路径掌握语法。

当前已完成阶段 6B：后端基础设施、英语 A1 核心数据模型、用户认证、公开课程目录、Lesson 答题学习闭环、错题 Review 复习闭环，以及可连接真实后端的 Flutter Android MVP。AI Tutor、订阅等业务尚未实现。

## 当前技术栈

- 后端：Java 21、Spring Boot 3.5、Maven
- 基础设施：PostgreSQL、Redis、Docker Compose
- 数据访问：MyBatis-Plus
- API 与认证：Spring Web、Validation、Spring Security、JWT、OpenAPI / Swagger UI
- 工程辅助：Lombok、MapStruct
- 移动端：Flutter 3.47、Dart 3.13、Riverpod、Dio、go_router、flutter_secure_storage、Material 3

## 目录说明

```text
grammar-agent/
├── backend/             # Spring Boot 后端
├── mobile/              # Flutter Android 客户端
├── admin/               # 管理端预留目录
├── docs/                # 项目文档
├── sql/                 # 数据库脚本预留目录
├── docker/              # Docker 扩展配置预留目录
├── .env.example         # 本地环境变量示例
├── .gitignore
├── docker-compose.yml   # PostgreSQL 与 Redis
└── README.md
```

## 本地启动依赖

- JDK 21
- Docker 与 Docker Compose
- macOS / Linux shell，或能够设置同名环境变量的其他终端

项目包含 Maven Wrapper，通常无需单独安装 Maven。

## 环境变量

先从示例创建仅供本机使用的配置文件：

```bash
cp .env.example .env
```

`.env` 已被 Git 忽略。首次使用前请修改其中的示例密码和 JWT Secret，不要提交真实凭据。

| 变量 | 用途 | 示例 |
| --- | --- | --- |
| `DB_HOST` | PostgreSQL 主机 | `localhost` |
| `DB_PORT` | PostgreSQL 端口 | `5432` |
| `DB_NAME` | 数据库名 | `grammar_agent` |
| `DB_USERNAME` | 数据库用户 | `grammar_agent` |
| `DB_PASSWORD` | 数据库密码 | 仅使用本地安全值 |
| `REDIS_HOST` | Redis 主机 | `localhost` |
| `REDIS_PORT` | Redis 端口 | `6379` |
| `REDIS_PASSWORD` | Redis 密码 | 仅使用本地安全值 |
| `JWT_SECRET` | JWT HMAC 签名密钥 | 至少 32 字节随机值 |
| `JWT_ACCESS_EXPIRE` | Access Token 有效秒数 | `900` |
| `JWT_REFRESH_EXPIRE` | Refresh Token 有效秒数 | `2592000` |
| `SERVER_PORT` | 后端监听端口 | `8080` |

## 启动 PostgreSQL 与 Redis

Docker Compose 会自动读取仓库根目录的 `.env`：

```bash
docker compose up -d
docker compose ps
```

停止服务：

```bash
docker compose down
```

命名卷会保留数据；只有显式执行 `docker compose down -v` 才会删除本地数据库数据。

## 启动 Spring Boot

`local` Profile 会从仓库根目录或 `backend/` 目录读取被 Git 忽略的 `.env`：

```bash
cd backend
./mvnw spring-boot:run
```

默认启用 `local` Profile。如需覆盖，可设置 `SPRING_PROFILES_ACTIVE`。

## 验证服务

Health API：

```bash
curl http://localhost:8080/api/v1/health
```

如果本机的 `8080` 已被 nginx 等程序占用，请在 `.env` 中设置 `SERVER_PORT=18080`，并将下方 URL 的端口相应改为 `18080`。不要同时保留多个不同版本的 GrammarAgent Java 进程，否则 `localhost` 可能命中旧实例。

预期返回：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "UP",
    "service": "grammar-agent-backend"
  },
  "timestamp": "2026-09-03T00:00:00Z"
}
```

OpenAPI JSON：<http://localhost:8080/v3/api-docs>

Swagger UI：<http://localhost:8080/swagger-ui.html>

## 用户认证 API

当前提供以下 `/api/v1` 接口：

| 方法 | 路径 | 是否公开 | 用途 |
| --- | --- | --- | --- |
| `POST` | `/auth/register` | 是 | email/password 注册并签发 Token |
| `POST` | `/auth/login` | 是 | 登录并签发 Token |
| `POST` | `/auth/refresh` | 是 | 轮换 Refresh Token |
| `POST` | `/auth/logout` | 否 | 撤销指定 Refresh Session |
| `GET` | `/users/me` | 否 | 获取当前登录用户资料 |

受保护接口使用请求头 `Authorization: Bearer <access-token>`。Swagger UI 的 **Authorize** 按钮可填写 Access Token。Refresh Session 使用 `auth:refresh:{tokenId}` 存入 Redis，Token 被刷新或登出后对应旧会话立即失效。

## 课程目录 API

以下课程结构查询接口均允许未登录访问，并且只返回启用内容：

| 方法 | 路径 | 用途 |
| --- | --- | --- |
| `GET` | `/languages` | 获取语言列表 |
| `GET` | `/languages/{languageCode}/levels` | 获取语言等级 |
| `GET` | `/levels/{levelId}/chapters` | 获取等级章节 |
| `GET` | `/chapters/{chapterId}/grammar-points` | 获取语法点摘要 |
| `GET` | `/grammar-points/{grammarPointId}` | 获取语法点详情和前置语法点 |
| `GET` | `/grammar-points/{grammarPointId}/lessons` | 获取 Lesson 列表 |
| `GET` | `/lessons/{lessonId}` | 获取 Lesson 详情，不包含题目 |
| `GET` | `/learning-path/{languageCode}` | 获取供客户端课程地图使用的完整结构树 |

所有路径统一使用 `/api/v1` 前缀。Learning Path 通过批量查询组装，不包含题目、正确答案或用户学习进度。

## 答题学习闭环 API

| 方法 | 路径 | 是否公开 | 用途 |
| --- | --- | --- | --- |
| `GET` | `/lessons/{lessonId}/questions` | 是 | 获取启用题目，不返回正确答案和解析 |
| `POST` | `/questions/{questionId}/answer` | 否 | 提交单题答案、判题并更新累计学习数据 |
| `POST` | `/lessons/{lessonId}/complete` | 否 | 按每题最新答案完成 Lesson 并结算 XP |

单题提交始终追加 `user_answers`，不会覆盖历史。单题响应中的 `xpEarned` 固定为 0，实际 Lesson XP 只在完成时按 `xpReward × correctCount ÷ totalCount` 结算，避免重复奖励。完整规则参见 [答题流程设计](docs/answer-flow.md)。

## 错题 Review API

以下接口全部要求 Bearer Access Token，用户身份只从认证上下文获取：

| 方法 | 路径 | 用途 |
| --- | --- | --- |
| `GET` | `/reviews/due?limit=20` | 获取已到期且未掌握的推荐复习队列，最多 100 条 |
| `GET` | `/reviews/wrong-questions?page=1&size=20` | 分页获取全部未掌握错题 |
| `GET` | `/reviews/summary` | 获取到期、未掌握、已掌握数量和最早复习时间 |
| `POST` | `/reviews/questions/{questionId}/answer` | 提交 Review 答案并更新错题及累计掌握度 |

Review 允许提前主动进行。Review 答对一次即标记 mastered，答错则累计错误次数并安排到 UTC 当前时间后 1 天；Review 不修改历史 Lesson 成绩，也不奖励 XP。完整规则参见 [Review 流程设计](docs/review-flow.md)。

## 编译与测试

```bash
cd backend
./mvnw clean package
```

## Flutter Android 开发

移动端开发环境需要 Flutter Stable、Android SDK（API 35 或更高）、Android Emulator，以及兼容 Flutter Android 构建的 JDK。本项目开发机使用 Flutter 3.47.2、Dart 3.13.2 与 JDK 21。

先启动基础设施和后端（当前开发端口为 `18080`）：

```bash
docker compose up -d

cd backend
SERVER_PORT=18080 ./mvnw spring-boot:run
```

启动 Android Emulator 后运行 App：

```bash
cd mobile
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:18080
```

Android Emulator 中的 `localhost` 指向模拟器自身，访问宿主 Mac 必须使用 `10.0.2.2`。`API_BASE_URL` 由统一的 `AppConfig` 读取；未传值时 Android 开发环境默认使用上述地址，生产环境必须显式传入 HTTPS 地址。

移动端质量检查和 Debug APK 构建：

```bash
cd mobile
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug \
  --dart-define=API_BASE_URL=http://10.0.2.2:18080
```

更完整的架构、页面和认证刷新说明见 [mobile/README.md](mobile/README.md)。
