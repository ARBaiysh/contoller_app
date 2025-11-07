# Inspector Mobile API - Документация для разработчика мобильного приложения

## Общие сведения

**Base URL:** `https://ca.asdf.kg` (продакшн)


**Формат данных:** JSON
**Кодировка:** UTF-8

## Аутентификация

Все эндпоинты (кроме `/api/auth/regions` и `/api/auth/login`) требуют JWT токен в заголовке:

```
Authorization: Bearer {JWT_TOKEN}
```

**Публичные эндпоинты** (не требуют авторизации):
- `GET /api/auth/regions` - получение списка регионов
- `POST /api/auth/login` - авторизация

---

## 1. Аутентификация

### 1.1. Получение списка регионов

**Endpoint:** `GET /api/auth/regions`

**Описание:** Получить список доступных регионов для выбора при входе. Не требует авторизации.

**Headers:** Не требуется

**Response 200:**
```json
[
  {
    "code": "karasy",
    "name": "Карасуу",
    "nameKg": "Карасуу"
  },
  {
    "code": "tokmok",
    "name": "Токмок",
    "nameKg": "Токмок"
  },
  {
    "code": "balykchy",
    "name": "Балыкчы",
    "nameKg": "Балыкчы"
  },
  {
    "code": "issyk-kul",
    "name": "Ысык-Көл",
    "nameKg": "Ысык-Көл"
  }
]
```

**Поля ответа:**
- `code` (string) - уникальный код региона (используется при логине)
- `name` (string) - название региона на русском
- `nameKg` (string) - название региона на кыргызском

**Кеширование:** Рекомендуется закешировать на весь жизненный цикл приложения

**Использование:**
1. Вызывается при первом запуске приложения
2. Пользователь выбирает регион из выпадающего списка
3. Выбранный `code` отправляется при логине в поле `regionCode`

---

### 1.2. Авторизация инспектора

**Endpoint:** `POST /api/auth/login`

**Описание:** Авторизация инспектора в системе. После успешной авторизации возвращается JWT токен и данные инспектора.

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
    "username": "02-09-1013",
    "password": "02091013",
    "regionCode": "karasy"
}
```

**Request Fields:**
- `username` (string, обязательно) - логин инспектора
- `password` (string, обязательно) - пароль инспектора
- `regionCode` (string, обязательно) - код региона (например: "karasy", "bishkek", "osh")

**Response 200 OK:**
```json
{
    "token": "eyJhbGciOiJIUzUxMiJ9.eyJyZWdpb25Db2RlIjoia2FyYXN5IiwiZXh0ZXJuYWxJZCI6ImJlYmI3MTMwLWM5YmUtMTFlMS04ZGQ2LTIwY2YzMGVlM2YwZSIsImluc3BlY3RvcklkIjo1LCJzdWIiOiIwMi0wOS0xMTE5IiwiaWF0IjoxNzYyMzY4MDY4LCJleHAiOjE3NjI0NTQ0Njh9.Ep7i82WLTz1whMIY4ze8D7ZSddVrD4TC0aUXu-OdFZlWAP09GwVz-ePknLCGgF2JQuFgsLJtEOQsJBalImHsVA",
    "inspector": {
        "id": 5,
        "username": "02-09-1119",
        "fullName": "Инспектор Тестовый",
        "externalId": "bebb7130-c9be-11e1-8dd6-20cf30ee3f0e",
        "regionCode": "karasy",
        "regionName": "Карасуу"
    }
}
```

**Response Fields:**
- `token` (string) - JWT токен для последующих запросов. Срок действия: 24 часа
- `inspector.id` (integer) - ID инспектора в базе данных
- `inspector.username` (string) - логин инспектора
- `inspector.fullName` (string) - ФИО инспектора
- `inspector.externalId` (string) - UUID инспектора в системе 1С
- `inspector.regionCode` (string) - код региона
- `inspector.regionName` (string) - название региона

**Response 400 Bad Request:**
```json
{
    "error": "Invalid credentials"
}
```

**Использование токена:**
Токен необходимо сохранить локально и использовать во всех последующих запросах в заголовке `Authorization: Bearer {token}`.

---

## 2. Профиль инспектора

### 2.1. Получить профиль

**Endpoint:** `GET /api/mobile/profile`

**Описание:** Получить данные текущего авторизованного инспектора.

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Response 200 OK:**
```json
{
    "id": 5,
    "username": "02-09-1119",
    "fullName": "Инспектор Тестовый",
    "externalId": "bebb7130-c9be-11e1-8dd6-20cf30ee3f0e",
    "regionCode": "karasy",
    "regionName": "Карасуу"
}
```

---

## 3. Трансформаторные подстанции (ТП)

### 3.1. Получить список ТП (из кеша)

**Endpoint:** `GET /api/mobile/transformer-points`

**Описание:** Получить список всех трансформаторных подстанций инспектора. Данные возвращаются из кеша (TTL: 30 минут).

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Query Parameters:**
- `forceRefresh` (boolean, optional, default: false) - если true, данные будут обновлены из 1С

**Response 200 OK:**
```json
[
    {
        "code": "1125",
        "name": "ТП №1130 Большевик",
        "active": true,
        "abonentCount": 45,
        "lastSync": "2025-01-15T10:30:00"
    },
    {
        "code": "129",
        "name": "ТП №129 Кантора сз Карас",
        "active": true,
        "abonentCount": 38,
        "lastSync": "2025-01-15T10:30:00"
    }
]
```

**Response Fields:**
- `code` (string) - уникальный код ТП
- `name` (string) - название ТП
- `active` (boolean) - активна ли ТП
- `abonentCount` (integer) - количество абонентов на данной ТП
- `lastSync` (string, ISO 8601) - время последней синхронизации с 1С

### 3.2. Получить список ТП (принудительно из 1С)

**Endpoint:** `GET /api/mobile/transformer-points?forceRefresh=true`

**Описание:** Получить список ТП с принудительным обновлением из 1С, игнорируя кеш.

**Headers, Response:** см. 3.1

---

## 4. Абоненты

### 4.1. Получить всех абонентов инспектора (из кеша)

**Endpoint:** `GET /api/mobile/abonents`

**Описание:** Получить список ВСЕХ абонентов по всем ТП инспектора. Данные из кеша (TTL: 30 минут).

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Query Parameters:**
- `forceRefresh` (boolean, optional, default: false)

**Response 200 OK:**
```json
[
    {
        "accountNumber": "09011250604",
        "fullName": "Алимов Бекжан Жумабекович",
        "address": "Карасуу г., Ленина ул., д.123",
        "phone": "+996770220406",
        "balance": -1500.50,
        "meterSerialNumber": "00001501",
        "currentReading": 93850,
        "previousReading": 93800,
        "lastReadingDate": "2025-01-10T14:30:00",
        "currentMonthConsumption": 50.0,
        "currentMonthCharge": 300.50,
        "lastPaymentDate": "2025-01-05T09:00:00",
        "lastPaymentAmount": 500.0,
        "tariff": 6.01,
        "transformerPointCode": "1125",
        "transformerPointName": "ТП №1130 Большевик",
        "contractDate": "2020-01-15",
        "notes": null
    }
]
```

**Response Fields:**
- `accountNumber` (string) - лицевой счет (ключевое поле)
- `fullName` (string) - ФИО абонента
- `address` (string) - адрес
- `phone` (string, nullable) - номер телефона
- `balance` (number) - баланс (положительное = долг, отрицательное = предоплата)
- `meterSerialNumber` (string) - серийный номер счетчика
- `currentReading` (integer) - текущее показание счетчика
- `previousReading` (integer) - предыдущее показание
- `lastReadingDate` (string, ISO 8601, nullable) - дата последнего показания
- `currentMonthConsumption` (number) - расход за текущий месяц (кВт⋅ч)
- `currentMonthCharge` (number) - начисление за текущий месяц (сомы)
- `lastPaymentDate` (string, ISO 8601, nullable) - дата последнего платежа
- `lastPaymentAmount` (number, nullable) - сумма последнего платежа
- `tariff` (number) - тариф (сом/кВт⋅ч)
- `transformerPointCode` (string) - код ТП
- `transformerPointName` (string) - название ТП
- `contractDate` (string, ISO 8601, nullable) - дата заключения договора
- `notes` (string, nullable) - примечания

### 4.2. Получить абонентов конкретной ТП (из кеша)

**Endpoint:** `GET /api/mobile/transformer-points/{tpCode}/abonents`

**Описание:** Получить список абонентов конкретной трансформаторной подстанции. Данные из кеша (TTL: 10 минут).

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Path Parameters:**
- `tpCode` (string) - код ТП (например: "1125", "129")

**Query Parameters:**
- `forceRefresh` (boolean, optional, default: false)

**Example:** `GET /api/mobile/transformer-points/1125/abonents`

**Response 200 OK:** Массив абонентов (см. 4.1)

### 4.3. Получить детальную информацию об абоненте (из кеша)

**Endpoint:** `GET /api/mobile/abonents/{accountNumber}`

**Описание:** Получить детальную информацию об абоненте по лицевому счету. Данные из кеша (TTL: 10 минут).

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Path Parameters:**
- `accountNumber` (string) - лицевой счет

**Query Parameters:**
- `forceRefresh` (boolean, optional, default: false)

**Example:** `GET /api/mobile/abonents/09011250604`

**Response 200 OK:** Объект абонента (см. 4.1)

**Response 400 Bad Request:**
```json
{
    "error": "Abonent not found in your region",
    "accountNumber": "09011250604"
}
```

**Важно:** API проверяет, что абонент принадлежит региону текущего инспектора. Если абонент из другого региона - возвращается ошибка.

### 4.4. Поиск абонентов (живой поиск)

**Endpoint:** `GET /api/mobile/abonents/search`

**Описание:** Живой поиск абонентов по нескольким полям. Возвращает максимум 30 результатов. Поиск только среди абонентов текущего инспектора.

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Query Parameters:**
- `query` (string, required, min: 1 символ) - поисковый запрос

**Поля поиска:**
- Лицевой счет (accountNumber)
- ФИО (fullName)
- Адрес (address)
- Телефон (phone)
- Серийный номер счетчика (meterSerialNumber)

**Особенности:**
- Поиск регистронезависимый
- Частичное совпадение (LIKE '%query%')
- Максимум 30 результатов
- Пустой запрос вернет пустой массив

**Example:** `GET /api/mobile/abonents/search?query=Алимов`

**Response 200 OK:** Массив абонентов (см. 4.1), максимум 30 элементов

**Response 200 OK (пустой запрос):**
```json
[]
```

### 4.5. Обновить номер телефона абонента

**Endpoint:** `POST /api/mobile/abonents/phone`

**Описание:** Обновить номер телефона абонента в системе 1С. Запрос синхронный - ожидается ответ от 1С.

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

**Request Body:**
```json
{
    "accountNumber": "09011250604",
    "phoneNumber": "+996770220406"
}
```

**Request Fields:**
- `accountNumber` (string, required) - лицевой счет
- `phoneNumber` (string, required) - новый номер телефона (формат: +996XXXXXXXXX)

**Response 200 OK:**
```json
{
    "success": true,
    "message": "Номер телефона успешно обновлен",
    "accountNumber": "09011250604",
    "phoneNumber": "+996770220406"
}
```

**Response 400 Bad Request:**
```json
{
    "error": "Abonent not found in your region",
    "accountNumber": "09011250604"
}
```

**Важно:**
- API проверяет, что абонент принадлежит региону текущего инспектора
- Номер телефона валидируется на стороне сервера
- Запрос отправляется в 1С и ожидается ответ (может занять 2-5 секунд)

---

## 5. Показания счетчиков

### 5.1. Отправить показание счетчика

**Endpoint:** `POST /api/mobile/meter-readings`

**Описание:** Отправить показание счетчика. Обработка происходит асинхронно через очередь. Возвращается ID показания для отслеживания статуса.

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

**Request Body:**
```json
{
    "accountNumber": "09011250604",
    "currentReading": 93850,
    "meterSerialNumber": "00001501"
}
```

**Request Fields:**
- `accountNumber` (string, required) - лицевой счет
- `currentReading` (integer, required) - текущее показание счетчика
- `meterSerialNumber` (string, optional) - серийный номер счетчика (для дополнительной валидации)

**Response 200 OK:**
```json
{
    "success": true,
    "message": "Показание принято в обработку",
    "readingId": 12345,
    "status": "PROCESSING"
}
```

**Response Fields:**
- `success` (boolean) - успешность операции
- `message` (string) - сообщение
- `readingId` (integer) - ID показания для отслеживания статуса
- `status` (string) - статус обработки (PROCESSING, COMPLETED, ERROR)

**Response 400 Bad Request:**
```json
{
    "error": "Validation failed: Current reading is less than previous reading",
    "accountNumber": "09011250604",
    "currentReading": 93850,
    "previousReading": 93900
}
```

**Валидация:**
- Текущее показание должно быть больше предыдущего
- Разница показаний не должна превышать разумные пределы (настраивается на сервере)

### 5.2. Проверить статус показания

**Endpoint:** `GET /api/mobile/meter-readings/{readingId}/status`

**Описание:** Проверить статус обработки показания счетчика.

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Path Parameters:**
- `readingId` (integer) - ID показания (получен из ответа 5.1)

**Example:** `GET /api/mobile/meter-readings/12345/status`

**Response 200 OK (обработка):**
```json
{
    "readingId": 12345,
    "status": "PROCESSING",
    "message": "Показание обрабатывается",
    "submittedAt": "2025-01-15T14:30:00"
}
```

**Response 200 OK (успешно):**
```json
{
    "readingId": 12345,
    "status": "COMPLETED",
    "message": "Показание успешно отправлено в 1С",
    "submittedAt": "2025-01-15T14:30:00",
    "completedAt": "2025-01-15T14:30:05",
    "oneCResponse": {
        "success": true,
        "message": "Показание принято"
    }
}
```

**Response 200 OK (ошибка):**
```json
{
    "readingId": 12345,
    "status": "ERROR",
    "message": "Ошибка отправки в 1С",
    "submittedAt": "2025-01-15T14:30:00",
    "completedAt": "2025-01-15T14:30:10",
    "error": "Connection timeout to 1C server"
}
```

**Статусы обработки:**
- `PROCESSING` - показание в очереди или обрабатывается
- `COMPLETED` - показание успешно отправлено в 1С
- `ERROR` - ошибка при отправке в 1С

---

## 6. Статистика (Дашборд)

### 6.1. Получить статистику инспектора

**Endpoint:** `GET /api/mobile/dashboard/stats`

**Описание:** Получить статистику по всем абонентам инспектора для отображения на главном экране.

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
```

**Response 200 OK:**
```json
{
    "totalAbonents": 972,
    "totalTransformerPoints": 18,
    "readingsThisMonth": 450,
    "totalCharge": 582195.75,
    "totalDebt": 217549.88,
    "totalPrepayment": 70155.81,
    "totalConsumption": 96850.0,
    "paymentCountThisMonth": 380,
    "totalPaymentAmount": 550000.0
}
```

**Response Fields:**
- `totalAbonents` (integer) - общее количество абонентов инспектора
- `totalTransformerPoints` (integer) - количество ТП инспектора
- `readingsThisMonth` (integer) - количество показаний, снятых в текущем месяце
- `totalCharge` (number) - общая сумма начислений за текущий месяц (сомы)
- `totalDebt` (number) - общая задолженность (сумма положительных балансов, сомы)
- `totalPrepayment` (number) - общая предоплата (сумма |отрицательных балансов|, сомы)
- `totalConsumption` (number) - общий расход электроэнергии за текущий месяц (кВт⋅ч)
- `paymentCountThisMonth` (integer) - количество абонентов, совершивших оплату в текущем месяце
- `totalPaymentAmount` (number) - общая сумма оплат за текущий месяц (сомы)

**Расчеты:**
- Данные рассчитываются на основе всех абонентов инспектора
- "Текущий месяц" = от 1-го числа текущего месяца до текущего момента
- Статистика обновляется при каждом запросе (не кешируется)

---

## 7. Кеширование и обновление данных

### Политика кеширования:

1. **Трансформаторные подстанции (ТП):**
   - TTL: 30 минут
   - Автоматическое обновление при истечении TTL
   - Ручное обновление: `forceRefresh=true`

2. **Все абоненты инспектора:**
   - TTL: 30 минут
   - Метка времени: `inspector.lastDataSync`
   - Автоматическое обновление при истечении TTL

3. **Абоненты конкретной ТП:**
   - TTL: 10 минут
   - Метка времени: `transformerPoint.lastSync`
   - Рекомендуется принудительное обновление перед началом обхода

4. **Детали абонента:**
   - TTL: 10 минут
   - Метка времени: `abonent.lastSync`
   - Рекомендуется принудительное обновление перед снятием показаний

### Рекомендации по работе с кешем:

**При запуске приложения:**
```
1. GET /api/mobile/profile
2. GET /api/mobile/dashboard/stats
3. GET /api/mobile/transformer-points (кеш OK)
```

**При начале обхода ТП:**
```
1. GET /api/mobile/transformer-points/{tpCode}/abonents?forceRefresh=true
```

**При снятии показаний:**
```
1. GET /api/mobile/abonents/{accountNumber}?forceRefresh=true
2. POST /api/mobile/meter-readings
3. GET /api/mobile/meter-readings/{readingId}/status (опционально)
```

**Pull-to-refresh на главном экране:**
```
1. GET /api/mobile/dashboard/stats
2. GET /api/mobile/transformer-points?forceRefresh=true
3. GET /api/mobile/abonents?forceRefresh=true
```

---

## 8. Обработка ошибок

### Стандартные HTTP коды:

- `200 OK` - успешный запрос
- `400 Bad Request` - ошибка валидации или бизнес-логики
- `401 Unauthorized` - отсутствует или невалиден JWT токен
- `403 Forbidden` - нет прав доступа к ресурсу
- `404 Not Found` - ресурс не найден
- `500 Internal Server Error` - внутренняя ошибка сервера

### Формат ошибки:

```json
{
    "error": "Описание ошибки на русском языке",
    "field": "имя_поля",
    "details": "Дополнительная информация"
}
```

### Типичные ошибки:

**401 Unauthorized:**
```json
{
    "error": "Invalid or expired JWT token"
}
```
**Действие:** Выполнить повторную авторизацию через `/api/auth/login`

**403 Forbidden (доступ к чужому абоненту):**
```json
{
    "error": "Abonent not found in your region"
}
```

**400 Bad Request (валидация):**
```json
{
    "error": "Current reading is less than previous reading",
    "accountNumber": "09011250604",
    "currentReading": 93850,
    "previousReading": 93900
}
```

**500 Internal Server Error:**
```json
{
    "error": "Failed to connect to 1C server"
}
```
**Действие:** Показать пользователю сообщение об ошибке, предложить повторить позже

---

## 9. Безопасность

### JWT токен:

- Срок действия: 24 часа
- Алгоритм: HS512
- Хранение: локальное хранилище приложения (Secure Storage)
- При истечении: повторная авторизация

### Проверки на стороне API:

1. **Региональная изоляция:**
   - Инспектор видит только абонентов своего региона
   - Попытка доступа к абонентам другого региона возвращает 403

2. **Валидация данных:**
   - Все входящие данные валидируются
   - Защита от SQL injection и XSS

3. **Rate limiting:**
   - Максимум 100 запросов в минуту на инспектора
   - При превышении: HTTP 429 Too Many Requests

### Рекомендации:

- Не храните JWT токен в незащищенном хранилище
- Не логируйте токен в консоль или файлы
- При выходе из приложения - удалите токен
- Используйте HTTPS в продакшене

---

## 10. Тестовые данные

### Тестовый инспектор (регион Карасуу):

```
username: 02-09-1013
password: 02091013
regionCode: karasy
```

### Тестовые лицевые счета:

- `09011250604` - Алимов Бекжан (ТП 1125)
- `02091112301` - Иванов Иван (ТП 129)
- `02091112302` - Петров Петр (ТП 129)

### Тестовые ТП:

- `1125` - ТП №1130 Большевик (~45 абонентов)
- `129` - ТП №129 Кантора сз Карас (~38 абонентов)
- `622` - ТП №622 Ц.у. Садс-з Карас (~52 абонента)

---

## 11. Примеры использования (User Flow)

### Сценарий 1: Авторизация и просмотр дашборда

```javascript
// 1. Авторизация
POST /api/auth/login
{
    "username": "02-09-1013",
    "password": "02091013",
    "regionCode": "karasy"
}

// Сохраняем токен из ответа
const token = response.token;

// 2. Получаем профиль
GET /api/mobile/profile
Headers: { Authorization: `Bearer ${token}` }

// 3. Получаем статистику для дашборда
GET /api/mobile/dashboard/stats
Headers: { Authorization: `Bearer ${token}` }

// Отображаем статистику на главном экране
```

### Сценарий 2: Обход ТП и снятие показаний

```javascript
// 1. Получаем список ТП
GET /api/mobile/transformer-points
Headers: { Authorization: `Bearer ${token}` }

// Пользователь выбирает ТП "1125"

// 2. Получаем абонентов выбранной ТП (принудительно из 1С)
GET /api/mobile/transformer-points/1125/abonents?forceRefresh=true
Headers: { Authorization: `Bearer ${token}` }

// Пользователь выбирает абонента "09011250604"

// 3. Получаем детали абонента (принудительно из 1С)
GET /api/mobile/abonents/09011250604?forceRefresh=true
Headers: { Authorization: `Bearer ${token}` }

// Пользователь вводит показание: 93850

// 4. Отправляем показание
POST /api/mobile/meter-readings
Headers: { Authorization: `Bearer ${token}` }
{
    "accountNumber": "09011250604",
    "currentReading": 93850,
    "meterSerialNumber": "00001501"
}

// Сохраняем readingId из ответа
const readingId = response.readingId;

// 5. Опционально: проверяем статус через 2-3 секунды
GET /api/mobile/meter-readings/${readingId}/status
Headers: { Authorization: `Bearer ${token}` }

// Если status === "COMPLETED" - показываем успех
// Если status === "ERROR" - показываем ошибку
// Если status === "PROCESSING" - показываем индикатор загрузки
```

### Сценарий 3: Поиск абонента

```javascript
// Пользователь вводит в поиск: "Алимов"

// 1. Выполняем поиск
GET /api/mobile/abonents/search?query=Алимов
Headers: { Authorization: `Bearer ${token}` }

// Отображаем результаты (до 30 абонентов)

// Пользователь выбирает абонента из списка

// 2. Получаем полную информацию
GET /api/mobile/abonents/09011250604
Headers: { Authorization: `Bearer ${token}` }

// Отображаем карточку абонента
```

### Сценарий 4: Обновление номера телефона

```javascript
// Пользователь в карточке абонента нажимает "Изменить номер"

// 1. Отправляем новый номер
POST /api/mobile/abonents/phone
Headers: {
    Authorization: `Bearer ${token}`,
    Content-Type: 'application/json'
}
{
    "accountNumber": "09011250604",
    "phoneNumber": "+996770220406"
}

// Показываем индикатор загрузки (запрос может занять 2-5 сек)

// 2. Обрабатываем ответ
if (response.success) {
    // Показываем успех
    // Обновляем локальные данные абонента
} else {
    // Показываем ошибку
}
```

---

## 12. Рекомендации по UI/UX

### Индикаторы загрузки:

- **Короткие запросы (< 1 сек):** минимальный индикатор или скелетон
- **Средние запросы (1-3 сек):** прогресс-бар или спиннер
- **Долгие запросы (> 3 сек):** полноэкранный индикатор с возможностью отмены

### Pull-to-refresh:

Рекомендуется на экранах:
- Дашборд: обновляет статистику и список ТП
- Список ТП: обновляет список из 1С
- Список абонентов ТП: обновляет абонентов из 1С

### Офлайн режим:

**Рекомендуется кешировать локально:**
- Список ТП
- Список абонентов каждой ТП
- Детали абонентов
- Неотправленные показания

**При отсутствии интернета:**
- Показывать кешированные данные с меткой "Последнее обновление: {время}"
- Сохранять показания локально
- При появлении интернета - синхронизировать в фоне

### Обработка ошибок:

**401 Unauthorized:**
- Автоматически перенаправлять на экран авторизации
- Сохранять текущее состояние для восстановления после авторизации

**400 Bad Request:**
- Показывать сообщение об ошибке понятным языком
- Подсвечивать проблемное поле

**500 Server Error:**
- Показывать friendly сообщение: "Сервер временно недоступен"
- Предлагать повторить попытку через несколько секунд

---

## 13. Производительность и оптимизация

### Минимизация трафика:

1. **Используйте кеш:** не делайте `forceRefresh=true` без необходимости
2. **Пагинация поиска:** поиск автоматически ограничен 30 результатами
3. **Lazy loading:** загружайте детали абонента только при открытии карточки

### Батчинг запросов:

Избегайте:
```javascript
// ❌ Плохо: N запросов в цикле
for (const accountNumber of accountNumbers) {
    await fetch(`/api/mobile/abonents/${accountNumber}`);
}
```

Используйте:
```javascript
// ✅ Хорошо: один запрос для всех абонентов ТП
const abonents = await fetch(`/api/mobile/transformer-points/${tpCode}/abonents`);
```

### Асинхронная отправка показаний:

Показания обрабатываются асинхронно:
1. Отправить показание → получить `readingId`
2. Показать пользователю "Показание принято"
3. В фоне проверять статус через 2-3 секунды
4. Обновить UI при завершении обработки

---

## 14. Changelog API

### Версия 1.2 (январь 2025)
- ✅ Добавлен эндпоинт поиска абонентов: `GET /api/mobile/abonents/search`
- ✅ Расширена статистика дашборда: добавлены поля `totalConsumption`, `paymentCountThisMonth`, `totalPaymentAmount`
- ✅ Ограничение результатов поиска до 30 записей

### Версия 1.1 (декабрь 2024)
- ✅ Добавлен эндпоинт обновления номера телефона: `POST /api/mobile/abonents/phone`
- ✅ Добавлен эндпоинт статистики дашборда: `GET /api/mobile/dashboard/stats`
- ✅ Улучшена обработка ошибок

### Версия 1.0 (ноябрь 2024)
- ✅ Базовая функциональность: авторизация, ТП, абоненты, показания

---

## 15. Контакты и поддержка

**Backend разработчик:** [указать контакты]
**API Issues:** [указать трекер задач]
**Postman Collection:** `Inspector_Mobile_API.postman_collection.json`

**Полезные ссылки:**
- Swagger UI (если доступен): `http://{server}:8270/swagger-ui.html`
- Health Check: `http://{server}:8270/actuator/health`

---

## 16. Глоссарий

- **ТП** - трансформаторная подстанция
- **Л/С** - лицевой счет (accountNumber)
- **1С** - система учета (внешняя система)
- **JWT** - JSON Web Token (токен авторизации)
- **TTL** - Time To Live (время жизни кеша)
- **Баланс** - положительное значение = долг, отрицательное = предоплата
- **Текущий месяц** - от 1-го числа текущего месяца до текущего момента
- **кВт⋅ч** - киловатт-час (единица измерения электроэнергии)

---

**Последнее обновление:** 15 января 2025
**Версия API:** 1.2
