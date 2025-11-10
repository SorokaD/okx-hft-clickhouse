# okx-hft-clickhouse

Локальная обвязка для ClickHouse под задачи ingestion и BI-аналитики окружения OKX HFT. Репозиторий позволяет быстро поднять единичный узел ClickHouse с типовыми политиками доступа и минимальным мониторингом.

## Быстрый старт
- Установите Docker и Docker Compose.
- Запустите сервисы: `docker compose up -d`.
- Проверьте состояние: `docker compose ps` и `docker compose logs clickhouse`.
- Зайдите в интерактивную консоль: `docker compose exec clickhouse clickhouse-client`.

По умолчанию ClickHouse доступен на портах `8123` (HTTP) и `9000` (native). Экспортёр метрик Prometheus слушает порт `9116`.

## Структура проекта
- `docker-compose.yml` — определение сервисов `clickhouse` и `clickhouse-exporter`.
- `config/config.d` — общие настройки сервера (хосты, TTL логов, макросы).
- `config/users.d` — пользователи, права и квоты.
- `config/profiles.d` — профили настроек ресурсов.
- `clickhouse_data` (Docker volume) — сохраняемая пользовательская база.

## Пользователи и доступ
| Пользователь | Пароль (по умолчанию) | Права | Назначение |
|--------------|----------------------|-------|------------|
| `admin`      | `admin_password`     | полный доступ, `access_management` | администрирование |
| `ingest`     | `ingest_password`    | `CREATE TABLE`, `INSERT` в `okx_raw.*` | загрузка данных |
| `bi_ro`      | `bi_ro_password`     | `SELECT` в `okx_core`, `okx_feat` | BI / аналитика |
| `default`    | без пароля, только localhost | дефолтный профиль | локальные запросы |

> ⚠️ Обновите пароли перед выкладкой в любое общее окружение.

## Настройки и профили
- `config/config.d/listen_hosts.xml` — разрешает подключения с хоста.
- `config/config.d/system_logs_ttl.xml` — TTL для системных логов (3–7 дней).
- `config/config.d/macros.xml` — кластеры и окружение (`okx_local`, `dev`).
- `config/profiles.d/limits.xml` — профиль `limited` с лимитами по памяти/потокам, используется пользователем `ingest`.
- `config/users.d/limits.xml` — квоты (при необходимости можно расширить).

При изменении конфигурации перезапустите сервис: `docker compose restart clickhouse`.

## Мониторинг
- Экспортёр `clickhouse-exporter` собирает базовые метрики и отдаёт их по HTTP на `http://localhost:9116/metrics`.
- Добавьте таргет в Prometheus: `- targets: ['host.docker.internal:9116']`.
- Логи контейнера: `docker compose logs -f clickhouse`.

## Полезные команды
- Создать бэкап volume: `docker run --rm -v clickhouse_data:/data -v %cd%:/backup busybox tar czf /backup/clickhouse_backup.tar.gz /data`.
- Очистить данные (удалит всё!): `docker compose down -v`.
- Обновить образ ClickHouse: `docker compose pull clickhouse && docker compose up -d`.

## Чек-лист перед продом
- [ ] Заменены пароли пользователей.
- [ ] Настроены firewall/ACL для внешних подключений.
- [ ] Настроен мониторинг в Prometheus/Grafana.
- [ ] Согласованы TTL логов и политика резервного копирования.

## Ссылки
- Документация ClickHouse: <https://clickhouse.com/docs>
- clickhouse-exporter (f1yegor): <https://github.com/f1yegor/clickhouse_exporter>