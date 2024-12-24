-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Дек 24 2024 г., 19:53
-- Версия сервера: 8.0.30
-- Версия PHP: 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `BusStation`
--
CREATE DATABASE IF NOT EXISTS `BusStation` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `BusStation`;

-- --------------------------------------------------------

--
-- Структура таблицы `buses`
--

CREATE TABLE `buses` (
  `id` int NOT NULL,
  `mark` varchar(50) NOT NULL,
  `number` varchar(50) NOT NULL,
  `capacity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `buses`
--

INSERT INTO `buses` (`id`, `mark`, `number`, `capacity`) VALUES
(1, 'MAZDA', 'M035RR', 28),
(2, 'MAZDA', 'R895EE', 50),
(3, 'MAZDA', 'T663NY', 45),
(4, 'MAZDA', 'U567LK', 80);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `count_routes`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `count_routes` (
`Станция` varchar(50)
,`Количество рейсов` bigint
);

-- --------------------------------------------------------

--
-- Структура таблицы `routes`
--

CREATE TABLE `routes` (
  `id` int NOT NULL,
  `stationId` int NOT NULL,
  `busId` int NOT NULL,
  `time` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `routes`
--

INSERT INTO `routes` (`id`, `stationId`, `busId`, `time`) VALUES
(1, 2, 1, '08:00:00'),
(2, 3, 4, '12:40:00'),
(3, 4, 3, '09:00:00'),
(4, 1, 2, '10:15:00'),
(5, 4, 1, '11:30:00'),
(6, 1, 2, '15:40:00');

-- --------------------------------------------------------

--
-- Структура таблицы `stations`
--

CREATE TABLE `stations` (
  `id` int NOT NULL,
  `stationName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Дамп данных таблицы `stations`
--

INSERT INTO `stations` (`id`, `stationName`) VALUES
(1, 'Набережная'),
(2, 'Весенняя'),
(3, 'Летняя'),
(4, 'Зимняя');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `sum_of_passengers`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `sum_of_passengers` (
`Общее количество пассажиров` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Структура для представления `count_routes`
--
DROP TABLE IF EXISTS `count_routes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `count_routes`  AS SELECT `s`.`stationName` AS `Станция`, count(`r`.`stationId`) AS `Количество рейсов` FROM (`stations` `s` join `routes` `r` on((`s`.`id` = `r`.`stationId`))) GROUP BY `r`.`stationId`, `s`.`stationName``stationName`  ;

-- --------------------------------------------------------

--
-- Структура для представления `sum_of_passengers`
--
DROP TABLE IF EXISTS `sum_of_passengers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `sum_of_passengers`  AS SELECT sum(`b`.`capacity`) AS `Общее количество пассажиров` FROM (`buses` `b` join `routes` `r` on((`b`.`id` = `r`.`busId`)))  ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `buses`
--
ALTER TABLE `buses`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `routes`
--
ALTER TABLE `routes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `busId` (`busId`),
  ADD KEY `stationId` (`stationId`);

--
-- Индексы таблицы `stations`
--
ALTER TABLE `stations`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `buses`
--
ALTER TABLE `buses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `routes`
--
ALTER TABLE `routes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `stations`
--
ALTER TABLE `stations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `routes`
--
ALTER TABLE `routes`
  ADD CONSTRAINT `routes_ibfk_1` FOREIGN KEY (`busId`) REFERENCES `buses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `routes_ibfk_2` FOREIGN KEY (`stationId`) REFERENCES `stations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
