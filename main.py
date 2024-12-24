import sys
from PyQt6 import QtWidgets
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QWidget, QLabel
from untitled import Ui_Form
import mysql.connector
import pandas as pd
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure


# Функция для подключения к базе данных
def connect_to_database():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="root",
        database="BusStation"
    )


class MainForm(QWidget):
    def __init__(self):
        super().__init__()
        self.ui = Ui_Form()  # Инициализация интерфейса
        self.ui.setupUi(self)  # Настройка UI из файла
        self.db_connection = connect_to_database()  # Подключение к базе данных

        # Привязка кнопок к методам
        self.ui.countRoetes.clicked.connect(self.CountRoutes)
        self.ui.countPassengers.clicked.connect(self.CountPassengers)
        self.ui.saveExel.clicked.connect(self.SaveToExel)

        # Инициализация контейнера для вывода текста и графиков
        self.chart_layout = self.ui.verticalLayout
        self.chart_canvas = None  # Для хранения графика
        self.text_label = QLabel("")
        self.text_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.text_label.setStyleSheet("font-size: 16px; color: black; background-color: #ffe1f0;")
        self.chart_layout.addWidget(self.text_label)

        # Хранилища для данных каждой кнопки
        self.data_routes = None  # Данные для "Количество рейсов"
        self.data_passengers = None  # Данные для "Количество пассажиров"

    # Функция для вывода текста
    def show_text(self, text):
        if self.chart_canvas:
            self.chart_layout.removeWidget(self.chart_canvas)
            self.chart_canvas.deleteLater()
            self.chart_canvas = None

        self.text_label.setText(text)
        self.text_label.show()

    # Функция для вывода графика
    def show_chart(self, data, x_label, y_label):
        self.text_label.hide()

        if self.chart_canvas:
            self.chart_layout.removeWidget(self.chart_canvas)
            self.chart_canvas.deleteLater()
            self.chart_canvas = None

        figure = Figure()
        ax = figure.add_subplot()
        stations = [row[0] for row in data]
        values = [row[1] for row in data]
        ax.bar(stations, values, color="pink")
        ax.set_title("График данных")
        ax.set_xlabel(x_label)
        ax.set_ylabel(y_label)

        self.chart_canvas = FigureCanvas(figure)
        self.chart_layout.addWidget(self.chart_canvas)
        self.chart_canvas.draw()

    # Функция работы кнопки "Посчитать количество рейсов"
    def CountRoutes(self):
        try:
            cursor = self.db_connection.cursor()
            cursor.execute("SELECT * FROM count_routes")
            countRoutes = cursor.fetchall()
            if countRoutes:
                self.data_routes = [[row[0], row[1]] for row in countRoutes]
                self.show_chart(self.data_routes, "Станция", "Количество рейсов")
            else:
                self.show_text("Нет данных.")
        except mysql.connector.Error as err:
            self.show_text(f"Ошибка: {err}")

    # Функция работы кнопки "Посчитать количество пассажиров"
    def CountPassengers(self):
        try:
            cursor = self.db_connection.cursor()
            cursor.execute("SELECT * FROM sum_of_passengers")
            totalPassengers = cursor.fetchone()
            if totalPassengers:
                self.data_passengers = [["Общее количество пассажиров", totalPassengers[0]]]
                self.show_text(f"Общее количество пассажиров: {totalPassengers[0]}")
            else:
                self.show_text("Нет данных.")
        except mysql.connector.Error as err:
            self.show_text(f"Ошибка: {err}")

    # Функция работы кнопки "Сохранить в Exel"
    def SaveToExel(self):
        try:
            # Флаг для проверки наличия данных
            has_data = False

            # Сохранение данных о маршрутах, если они есть
            if self.data_routes:
                df_routes = pd.DataFrame(self.data_routes, columns=["Станция", "Количество рейсов"])
                file_path_routes = "data_output_count_routes.xlsx"
                df_routes.to_excel(file_path_routes, index=False, engine='openpyxl')
                has_data = True

            # Сохранение данных о пассажирах, если они есть
            if self.data_passengers:
                df_passengers = pd.DataFrame(self.data_passengers, columns=["Описание", "Значение"])
                file_path_passengers = "data_output_count_passengers.xlsx"
                df_passengers.to_excel(file_path_passengers, index=False, engine='openpyxl')
                has_data = True

            # Вывод сообщения в зависимости от наличия данных
            if has_data:
                self.show_text("Данные успешно сохранены.")
            else:
                self.show_text("Нет данных для сохранения.")
        except Exception as e:
            self.show_text(f"Ошибка при сохранении: {str(e)}")


# Основной блок программы
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    window = MainForm()
    window.show()
    sys.exit(app.exec())
