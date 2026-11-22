-- Создание базы данных (если требуется)
CREATE DATABASE PandoraDollWorkshop;
GO
USE PandoraDollWorkshop;
GO

-- 1. Таблица клиентов (Независимая)
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100)
);
GO

-- 2. Таблица кукольников (Независимая)
-- Примечание: по правилам из задания таблицы должны быть во мн. числе (Designers), 
-- но я оставил Designer, как на вашей схеме.
CREATE TABLE Designer (
    DesignerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(20),
    WorkCost DECIMAL(12,2) NOT NULL
);
GO

-- 3. Таблица сложности (Независимая)
CREATE TABLE Complexities (
    ComplexityID INT IDENTITY(1,1) PRIMARY KEY,
    ComplexityName NVARCHAR(50) NOT NULL,
    ExpectedTime INT NOT NULL
);
GO

-- 4. Таблица категорий материалов (Независимая)
CREATE TABLE MaterialCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL
);
GO

-- 5. Таблица стилей / типов кукол (Зависит от Complexities)
CREATE TABLE Styles (
    StyleID INT IDENTITY(1,1) PRIMARY KEY,
    StyleName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(200),
    ComplexityID INT,
    FOREIGN KEY (ComplexityID) REFERENCES Complexities(ComplexityID)
);
GO

-- 6. Таблица материалов (Зависит от MaterialCategories)
CREATE TABLE Materials (
    MaterialID INT IDENTITY(1,1) PRIMARY KEY,
    MaterialName NVARCHAR(150) NOT NULL,
    CategoryID INT,
    Price DECIMAL(12,2) NOT NULL,
    Stock DECIMAL(10,2) NOT NULL,
    ExpectedDate DATETIME,
    FOREIGN KEY (CategoryID) REFERENCES MaterialCategories(CategoryID)
);
GO

-- 7. Таблица заказов (Зависит от Clients, Designer, Styles)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT NOT NULL,
    DesignerID INT NOT NULL,
    StyleID INT NOT NULL,
    OrderDate DATE NOT NULL,
    InterimAssemblyDate DATETIME,
    Status NVARCHAR(50),
    ActualCompletionDate DATE,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (DesignerID) REFERENCES Designer(DesignerID),
    FOREIGN KEY (StyleID) REFERENCES Styles(StyleID)
);
GO

-- 8. Таблица связи "Стиль-Материал" (Зависит от Styles и Materials)
-- Реализует связь Многие-ко-Многим (базовый состав стиля)
CREATE TABLE StyleMaterials (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    StyleID INT NOT NULL,
    MaterialID INT NOT NULL,
    FOREIGN KEY (StyleID) REFERENCES Styles(StyleID),
    FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID)
);
GO

-- 9. Таблица состава конкретного заказа (Зависит от Orders и Materials)
-- Реализует связь Многие-ко-Многим (какие материалы пошли на заказ)
CREATE TABLE OrderMaterials (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    MaterialID INT NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL,
    Price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MaterialID) REFERENCES Materials(MaterialID)
);
GO-- Заполнение Clients (5 записей)
INSERT INTO Clients (FullName, Phone, Email) VALUES 
(N'Иванова Анна Сергеевна', '+7(999)111-22-33', 'anna@mail.ru'),
(N'Петров Иван Игоревич', '+7(999)222-33-44', 'ivan@mail.ru'),
(N'Сидорова Мария Олеговна', '+7(999)333-44-55', 'maria@mail.ru'),
(N'Кузнецов Артем Дмитриевич', '+7(999)444-55-66', 'artem@mail.ru'),
(N'Смирнова Елена Владимировна', '+7(999)555-66-77', 'elena@mail.ru');

-- Заполнение Designer (3 записи)
INSERT INTO Designer (FullName, Phone, WorkCost) VALUES 
(N'Орлова Ольга Петровна', '+7(911)100-10-10', 3500.00),
(N'Никитин Сергей Анатольевич', '+7(911)200-20-20', 4200.00),
(N'Федорова Дарья Максимовна', '+7(911)300-30-30', 5000.00);

-- Заполнение Complexities (3 записи)
INSERT INTO Complexities (ComplexityName, ExpectedTime) VALUES 
(N'Простая', 48),    -- часы
(N'Средняя', 96),
(N'Высокая', 144);

-- Заполнение MaterialCategories (3 записи)
INSERT INTO MaterialCategories (CategoryName) VALUES 
(N'Ткани для тела'),
(N'Ткани для одежды'),
(N'Фурнитура и декор');

-- Заполнение Styles (4 записи)
INSERT INTO Styles (StyleName, Description, ComplexityID) VALUES 
(N'Кукла "Классика"', N'Традиционная фарфоровая кукла', 2),
(N'Тильда "Заяц"', N'Мягкая текстильная игрушка', 1),
(N'Шарнирная кукла BJD', N'Подвижная кукла с шарнирами', 3),
(N'Интерьерная кукла "Дама"', N'Крупная кукла для декора', 2);

-- Заполнение Materials (6 записей)
INSERT INTO Materials (MaterialName, CategoryID, Price, Stock, ExpectedDate) VALUES 
(N'Хлопок белый', 1, 450.00, 15.5, '2025-12-01'),
(N'Лен телесного цвета', 1, 600.00, 10.0, '2025-11-25'),
(N'Кружево французское', 2, 1200.00, 5.0, '2025-12-05'),
(N'Бархат синий', 2, 950.00, 8.0, NULL),
(N'Глаза стеклянные (пара)', 3, 350.00, 20.0, '2025-11-20'),
(N'Шарниры пластиковые (комплект)', 3, 800.00, 6.0, '2025-12-10');

-- Заполнение StyleMaterials (базовый состав) (6 записей)
INSERT INTO StyleMaterials (StyleID, MaterialID) VALUES 
(1, 1), -- Классика: Хлопок
(1, 5), -- Классика: Глаза
(2, 1), -- Тильда: Хлопок
(3, 6), -- BJD: Шарниры
(3, 5), -- BJD: Глаза
(4, 4); -- Дама: Бархат

-- Заполнение Orders (5 записей)
INSERT INTO Orders (ClientID, DesignerID, StyleID, OrderDate, InterimAssemblyDate, Status, ActualCompletionDate) VALUES 
(1, 1, 2, '2025-11-01', '2025-11-05 14:00:00', N'Выполнен', '2025-11-06'),
(2, 3, 3, '2025-11-10', '2025-11-20 10:00:00', N'В процессе', NULL),
(3, 2, 1, '2025-11-12', '2025-11-18 12:00:00', N'В процессе', NULL),
(1, 2, 4, '2025-11-15', '2025-11-25 15:00:00', N'Планируется', NULL),
(4, 1, 2, '2025-11-18', '2025-11-22 09:00:00', N'Планируется', NULL);

-- Заполнение OrderMaterials (какие материалы пошли на заказы) (6 записей)
INSERT INTO OrderMaterials (OrderID, MaterialID, Quantity, Price) VALUES 
(1, 1, 2.5, 450.00),
(2, 6, 1.0, 800.00),
(2, 5, 1.0, 350.00),
(3, 1, 3.0, 450.00),
(3, 5, 1.0, 350.00),
(4, 4, 4.5, 950.00);
GO