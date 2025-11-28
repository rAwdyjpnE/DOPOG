# 🚛 DOPOG: Обновление механик и UI (ADR System)

> **Статус:** Рефакторинг + обновление
> **Версия движка:** Godot 4.5.1
> **Основной фокус:** UI, UX, Анимации, Оптимизация сцены с 3д

---

## 📋 Краткий отчет о проделанной работе

Изменен UI.
### Основные изменения:
1.  **Новый UI:** Реализована выезжающая панель стикеров, боковое меню инструментов и верхняя панель задания.
2.  **Анимации:** Добавлена сочная анимация наклеивания ("Elastic Pop") и плавный зум камеры.
3.  **UX:** Подсветка выбранного стикера.

---

## 📂 Структура файлов и зоны ответственности

Ниже приведен список ключевых файлов, с которыми велась работа, и их назначение.

### 1. Скрипты (`src/Scripts/`)

| Файл | Описание |
| :--- | :--- |
| **`Input.gd`** | **Ядро логики.** Отвечает за рейкаст (определение клика), спавн стикеров, анимацию их появления, вращение модели (WASD) и зум камеры. |
| **`StickerPanel.gd`** | **Логика панели стикеров.** Генерирует кнопки на основе списка файлов, управляет анимацией выезда панели и подсветкой выбранного элемента. |
| **`SidebarButtons.gd`** | **Боковое меню.** Связывает кнопки интерфейса (открыть панель, ластик) с основной логикой. |

### 2. Сцены (`src/Scenes/`)

| Сцена | Описание |
| :--- | :--- |
| **`Quest.tscn`** | **Игровая сцена.** Содержит 3D-мир, настроенное освещение, камеру и слой UI (`CanvasLayer`). |
| **`test.tscn`** | **Главное меню.** Стартовая точка входа. |
| **`result.tscn`** | **Экран результатов.** Показывает итог и возвращает в меню. |

---

## 🛠️ Технический разбор

Здесь приведены ключевые фрагменты кода для понимания реализации новых механик.

### 1. Анимация наклеивания
Вместо сложных шейдеров используем надежную анимацию свойств `Decal`. Стикер появляется с нулевым размером и "выпрыгивает" с эффектом пружины.

```src/Scripts/Input.gd
func _place_sticker() -> void:
    # ... (проверки рейкаста) ...
    
    # Создаем стикер
    var sticker: Decal = create_sticker()

    if sticker:
        # 1. Начальное состояние: маленький и прозрачный
        sticker.scale = Vector3(0.01, 0.01, 0.01)
        sticker.albedo_mix = 0.0
        
        # 2. Настройка Tween (аниматора)
        var tween = create_tween()
        tween.set_parallel(true) # Запускаем анимации одновременно
        tween.set_ease(Tween.EASE_OUT)
        
        # 3. Эффект пружины (Elastic) для масштаба
        tween.set_trans(Tween.TRANS_ELASTIC)
        tween.tween_property(sticker, "scale", Vector3(1, 1, 1), 0.5)
        
        # 4. Плавное появление (Linear) для прозрачности
        tween.set_trans(Tween.TRANS_LINEAR) 
        tween.tween_property(sticker, "albedo_mix", 1.0, 0.3)
```

### 2. Система Зума
Реализовано плавное приближение и отдаление камеры с ограничением (clamp).

```src/Scripts/Input.gd
const ZOOM_SPEED = 0.5
const MIN_ZOOM = 3.0
const MAX_ZOOM = 10.0

func _input(event) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _zoom_camera(-ZOOM_SPEED) # Приближение
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _zoom_camera(ZOOM_SPEED)  # Отдаление

func _zoom_camera(amount: float) -> void:
    if not camera: return
    # Ограничиваем зум
    target_zoom = clamp(target_zoom + amount, MIN_ZOOM, MAX_ZOOM)
    
    # Плавная интерполяция позиции
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(camera, "position:z", target_zoom, 0.2)
```

### 3. Подсветка выбранного стикера
В UI добавлена зеленая рамка, которая перемещается между кнопками при клике.

```src/Scripts/StickerPanel.gd
func _on_sticker_clicked(btn: TextureButton, path: String) -> void:
    # Снимаем рамку с предыдущей кнопки
    if selected_btn != null and is_instance_valid(selected_btn):
        var old_border = selected_btn.get_node_or_null("SelectionBorder")
        if old_border: old_border.visible = false

    # Назначаем новую активную кнопку
    selected_btn = btn

    # Включаем рамку на новой кнопке
    var new_border = selected_btn.get_node_or_null("SelectionBorder")
    if new_border: new_border.visible = true

    # Передаем данные в основную логику
    if main_script:
        main_script.set_active_sticker(path)
```

---

## 🚀 Как запустить и проверить

1. Открыть проект в Godot 4.5.1.
2. Запустить сцену **`src/Scenes/test.tscn`** (Главное меню).
3. Нажать **"Начать тест"**.
4. В сцене задания:
   - **ЛКМ**: Наклеить стикер.
   - **Колесико**: Зум.
   - **WASD / Стрелки**: Вращение контейнера.
   - **Кнопка 📋**: Открыть панель стикеров.
   - **Кнопка 🧹**: Удалить все стикеры.
   - **Кнопка E**: Сменить модель.
   - **Кнопка Q**: Удалить последний стикер.
