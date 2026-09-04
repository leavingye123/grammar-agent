# GrammarAgent

GrammarAgent 是一款专注于外语语法学习与练习的智能学习产品。产品将通过关卡、进度、XP、连续学习天数和即时反馈，帮助学习者沿着由易到难的路径掌握语法。

当前处于阶段 1：搭建可运行的 Spring Boot 后端基础工程。MVP 首期面向英语 A1，并优先发布 Android 客户端；用户、课程、题目、AI Tutor、订阅等业务尚未实现。

## 当前技术栈

- 后端：Java 21、Spring Boot 3.5、Maven
- 基础设施：PostgreSQL、Redis、Docker Compose
- 数据访问：MyBatis-Plus
- API：Spring Web、Validation、Spring Security、OpenAPI / Swagger UI
- 工程辅助：Lombok、MapStruct
- 移动端规划：Flutter（本阶段尚未开发）

## 目录说明

```text
grammar-agent/
├── backend/             # Spring Boot 后端
├── mobile/              # Flutter 客户端预留目录
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
| `JWT_SECRET` | JWT 签名密钥预留项 | 至少 32 字节随机值 |
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

Spring Boot 不会自动把 Docker Compose 的 `.env` 注入当前 shell，因此启动前需导出变量：

```bash
set -a
source .env
set +a
cd backend
./mvnw spring-boot:run
```

默认启用 `local` Profile。如需覆盖，可设置 `SPRING_PROFILES_ACTIVE`。

## 验证服务

Health API：

```bash
curl http://localhost:8080/api/v1/health
```

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

## 编译与测试

```bash
cd backend
./mvnw clean package
```
