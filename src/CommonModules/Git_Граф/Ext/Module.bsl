
#Область ПрограммныйИнтерфейс

// Входная функция для создания HTML документа с графом коммитов
//
// Параметры:
//   Коммиты - Массив - 
//
// Возвращаемое значение
//   Строка - итоговый HTML документ
//
Функция Визуализировать(Коммиты) Экспорт
	
	ДоступныеЦвета = Новый Массив;
	Точки = Новый Массив;
	Ветви = Новый Массив;
	Настройки = Настройки();
	Элементы = Новый Массив;

	ОбработанныеКоммиты = Новый Соответствие;
	
	// TODO: добаавить null точку
	Для Сч = 0 По Коммиты.Количество() - 1 Цикл
		ОбработанныеКоммиты[Коммиты[Сч].hash] = Сч;
		Точки.Добавить(Git_ГрафТочка.Создать(Сч));
	КонецЦикла;
	Сч = 0;
	Для каждого Коммит Из Коммиты Цикл
		Для каждого Родитель Из Коммит.parents Цикл
			ТочкаКоммитаРодителя = ОбработанныеКоммиты[Родитель];
			Если Не ТочкаКоммитаРодителя = Неопределено Тогда
				Git_ГрафТочка.ДобавитьРодителя(Точки[Сч], Точки[ТочкаКоммитаРодителя]);
				Git_ГрафТочка.ДобавитьПотомка(Точки[ТочкаКоммитаРодителя], Точки[Сч]);
			Иначе
				// TODO: Пока не до конца понятная логика с null точкой
			КонецЕсли;
		КонецЦикла;

		Сч = Сч + 1;
	КонецЦикла;
	
	// TODO: uncommited
	// TODO: set current
	
	Для каждого Точка Из Точки Цикл
		Если Не Git_ГрафТочка.СледующийРодитель(Точка) = Неопределено
			Или Git_ГрафТочка.НеПринадлежитВетви(Точка)
		Тогда
			НоваяВетка = ОпределитьПуть(Точка, Точки, ДоступныеЦвета);
			Если Не НоваяВетка = Неопределено Тогда
				Ветви.Добавить(НоваяВетка);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Для каждого Ветвь Из Ветви Цикл
		Результат = Git_ГрафВетвь.Визуализировать(Ветвь, Настройки);
		Элементы.Добавить(Результат);;
	КонецЦикла;
	Для каждого Точка Из Точки Цикл
		Результат = Git_ГрафТочка.Визуализировать(Точка, Настройки);
		Если Не Результат = Неопределено Тогда
			Элементы.Добавить(Результат);;
		КонецЕсли;
	КонецЦикла;
	
	Svg = СтрСоединить(Элементы, Символы.ПС);
	Высота = Высота(Точки, Настройки);
	Ширина = Ширина(Точки, Настройки);
	
	Таблица = ТаблицаКоммитов(Коммиты, ОбработанныеКоммиты, Ширина);
	Html = СтрШаблон(ШаблонHtml(), Svg, Таблица, "100%", Ширина, Высота);
		
	Возврат Html;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОпределитьПуть(Знач Точка, Точки, ДоступныеЦвета)
	
	Начало = Точка.Идентификатор;
	Родитель = Git_ГрафТочка.СледующийРодитель(Точка);
	ПоследняяПозиция = ?(Git_ГрафТочка.НеПринадлежитВетви(Точка),
		Git_ГрафТочка.СледующаяПозиция(Точка), Git_ГрафТочка.ТекущаяПозиция(Точка));
	
	Если Не Родитель = Неопределено
		// TODO: Пока не до конца понятная логика с null точкой
		И Git_ГрафТочка.ЭтоОбъединение(Точка)
		И Не Git_ГрафТочка.НеПринадлежитВетви(Точка)
		И Не Git_ГрафТочка.НеПринадлежитВетви(Родитель)
	Тогда
	
		НайденаПозицияРодителя = Ложь;
		РодительскаяВетвь = Родитель.Ветвь;
		Для Сч = Начало + 1 По Точки.Количество() - 1 Цикл
		
			ТекущийЭлемент = Точки[Сч];
			ТекущаяПозиция = Git_ГрафТочка.ПрисоединеннаяПозиция(ТекущийЭлемент, Родитель, РодительскаяВетвь);
			Если Не ТекущаяПозиция = Неопределено Тогда
				НайденаПозицияРодителя = Истина;
			Иначе
				ТекущаяПозиция = Git_ГрафТочка.СледующаяПозиция(ТекущийЭлемент);
			КонецЕсли;
			
			Git_ГрафВетвь.ДобавитьЛинию(РодительскаяВетвь, ПоследняяПозиция, ТекущаяПозиция,
				Не НайденаПозицияРодителя И Не ТекущийЭлемент = Родитель);
			Git_ГрафТочка.ЗарегистрироватьНедоступнуюТочку(ТекущийЭлемент, ТекущаяПозиция.X, Родитель, РодительскаяВетвь);
			ПоследняяПозиция = ТекущаяПозиция;
			
			Если НайденаПозицияРодителя Тогда
				Git_ГрафТочка.УстановитьРодительОбработан(Точка);
				Прервать;
			КонецЕсли;
		
		КонецЦикла;
		
	Иначе
		
		Ветвь = Git_ГрафВетвь.Создать(
			ДоступныйЦвет(Начало, ДоступныеЦвета));
		Git_ГрафТочка.ДобавитьКВетви(Точка, Ветвь, ПоследняяПозиция.X);
		Git_ГрафТочка.ЗарегистрироватьНедоступнуюТочку(Точка, ПоследняяПозиция.X, Точка, Ветвь);
		Для Сч = Начало + 1 По Точки.Количество() - 1 Цикл
			
			ТекущийЭлемент = Точки[Сч];
			ТекущаяПозиция = ?(Родитель = ТекущийЭлемент И Не Git_ГрафТочка.НеПринадлежитВетви(Родитель),
				Git_ГрафТочка.ТекущаяПозиция(ТекущийЭлемент), Git_ГрафТочка.СледующаяПозиция(ТекущийЭлемент));
				
			Git_ГрафВетвь.ДобавитьЛинию(Ветвь, ПоследняяПозиция, ТекущаяПозиция, ПоследняяПозиция.X < ТекущаяПозиция.X);
			Git_ГрафТочка.ЗарегистрироватьНедоступнуюТочку(ТекущийЭлемент, ТекущаяПозиция.X, Родитель, Ветвь);
			ПоследняяПозиция = ТекущаяПозиция;
			
			Если Не Родитель = Неопределено И Родитель.Идентификатор = ТекущийЭлемент.Идентификатор Тогда
				
				Git_ГрафТочка.УстановитьРодительОбработан(Точка);
				РодительНеПринадлежитВетви = Не Git_ГрафТочка.НеПринадлежитВетви(Родитель);
				Git_ГрафТочка.ДобавитьКВетви(Родитель, Ветвь, ТекущаяПозиция.X);
				Точка = Родитель;
				Родитель = Git_ГрафТочка.СледующийРодитель(Точка);
				Если Родитель = Неопределено Или РодительНеПринадлежитВетви Тогда
					Прервать;
				КонецЕсли;
				
			КонецЕсли;
				
		КонецЦикла;
		
		Если Сч = Точки.Количество() И Не Родитель = Неопределено Тогда // TODO: Пока не до конца понятная логика с null точкой
			Git_ГрафТочка.УстановитьРодительОбработан(Точка);
		КонецЕсли;
		
		Git_ГрафВетвь.УстановитьКонец(Ветвь, Сч);
		ДоступныеЦвета[Ветвь.Цвет] = Сч;
		
		Возврат Ветвь;
		
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ТаблицаКоммитов(Коммиты, ОбработанныеКоммиты, Ширина)
	
	Html = Новый Массив;;
	
	Для каждого Коммит Из Коммиты Цикл
		
		Сообщение = СтрШаблон("<span class=""text"">%1</span>", Коммит.subject);
		
		Html.Добавить(СтрШаблон("<tr class=""commit"" data-id=""%1"" data-color=""%2"">
		|  <td></td>
		|  <td><span class=""description"">%3</span></td>
		|  <td class=""dateCol text"" title=""%4"">%5</td>
		|  <td class=""authorCol text"" title=""%6 &lt;%7&gt;"">%6</td>
		|  <td class=""text"" title=""%8"">%9</td>
		|</tr>",
			Формат(ОбработанныеКоммиты[Коммит.hash], "ЧН=; ЧГ=0"),
			,
			Сообщение,
			,
			ДатаКоммита(Коммит.author.timestamp),
			Коммит.author.name,
			Коммит.author.email,
			Коммит.hash,
			Коммит.hashAbbrev));
		
	КонецЦикла;
	
	Возврат СтрШаблон("<table>
	|  <tr id=""tableColHeaders"">
	|    <th id=""tableHeaderGraphCol"" class=""tableColHeader"" data-col=""0"" width=""%2px"">Граф</th>
	|    <th class=""tableColHeader"" data-col=""1"">Описание</th>
	|    <th class=""tableColHeader dateCol"" data-col=""2"">Дата</th>
	|    <th class=""tableColHeader authorCol"" data-col=""3"">Автор</th>
	|    <th class=""tableColHeader"" data-col=""4"">Хэш</th>
	|  </tr>
	|%1
	|</table>",
		СтрСоединить(Html, Символы.ПС), Ширина);
	
КонецФункции

Функция Настройки()
	
	МассивЦветов = Новый Массив;
	МассивЦветов.Добавить("#0085d9");
	МассивЦветов.Добавить("#d9008f");
	МассивЦветов.Добавить("#00d90a");
	МассивЦветов.Добавить("#d98500");
	МассивЦветов.Добавить("#a300d9");
	МассивЦветов.Добавить("#ff0000");
	МассивЦветов.Добавить("#00d9cc");
	МассивЦветов.Добавить("#e138e8");
	МассивЦветов.Добавить("#85d900");
	МассивЦветов.Добавить("#dc5b23");
	МассивЦветов.Добавить("#6f24d6");
	МассивЦветов.Добавить("#ffcc00");
	
	Сетка = Новый Структура("X, Y, ОтступX, ОтступY",
		16, 24, 16, 12);
	
	Возврат Новый Структура("Сетка, Цвета",
		Сетка, МассивЦветов);;
	
КонецФункции

Функция ШаблонHtml()
	
	Возврат "
	|<html>
	|  <head>
	|    <style>
	|      body{
	|        display:block;
	|        position:fixed;
	|        top:0;
	|        left:0;
	|        right:0;
	|        bottom:0;
	|        margin:0;
	|        padding:0;
	|        font-family: Arial;
	|        font-size: 10pt;
	|      }
	|      .container{
	|        position:relative;
	|      }
	|      .graph{
	|        display:block;
	|        position:absolute;
	|        left:0;
	|        top:0;
	|        z-index:2;
	|        pointer-events:none;
	|      }
	|      .graph circle{
	|        pointer-events:all;
	|      }
	|      .graph circle.current{
	|        fill:var(--vscode-editor-background);
	|        stroke-width:2;
	|      }
	|      .graph circle:not(.current){
	|        stroke:var(--vscode-editor-background);
	|        stroke-width:1;
	|        stroke-opacity:0.75;
	|      }
	|      .graph circle.stashInner{
	|        stroke-opacity:1;
	|        pointer-events:none;
	|        fill:transparent;
	|      }
	|      .graph path.shadow{
	|        fill:none;
	|        stroke:var(--vscode-editor-background);
	|        stroke-opacity:0.75;
	|        stroke-width:4;
	|      }
	|      .graph path.line{
	|        fill:none;
	|        stroke-width:2;
	|      }
	|
	|      /* Таблица коммитов */
	|      #commitTable{
	|        z-index:1;
	|      }
	|      #commitTable table{
	|        width:%3;
	|        border-collapse:collapse;
	|      }
	|      #commitTable table, #commitTable tbody, #commitTable tr, #commitTable th, #commitTable td{
	|        padding:0;
	|        margin:0;
	|      }
	|      #commitTable th, #commitTable td{
	|        white-space:nowrap;
	|        font-size:13px;
	|        cursor:default;
	|        text-overflow:ellipsis;
	|        overflow:hidden;
	|      }
	|      #commitTable td{
	|        line-height:24px;
	|        padding:0 4px;
	|      }
	|      #commitTable th{
	|        border-bottom:1px solid rgba(128,128,128,0.5);
	|        line-height:18px;
	|        padding:6px 12px;
	|      }
	|      #commitTable tr.commit.current span.description .text{
	|        font-weight:bold;
	|      }
	|      #commitTable tr.commit span.description{
	|        display:flex;
	|      }
	|      #commitTable tr.commit span.description .commitHeadDot, #commitTable tr.commit td span.description .gitRef{
	|        flex-shrink:0;
	|      }
	|      #commitTable tr.commit span.description .text{
	|        display:inline-block;
	|        text-overflow:ellipsis;
	|        white-space:nowrap;
	|        overflow:hidden;
	|        flex-grow:1;
	|      }
	|      #commitTable tr.commit.mute td.text, #commitTable tr.commit.mute span.description .text{
	|        opacity:0.5;
	|      }
	// TODO: пока этиф стили не используются. Оставил на будущее. Чтобы не забыть
	//|      #commitTable.fixedLayout table{
	//|        table-layout:fixed;
	//|      }
	//|      #commitTable.autoLayout.limitGraphWidth td:first-child, #commitTable.autoLayout.limitGraphWidth th:first-child{
	//|        max-width:var(--limitGraphWidth);
	//|        box-sizing:border-box;
	//|      }
	//|      #commitTable.autoLayout td:nth-child(2), #commitTable.autoLayout th:nth-child(2){
	//|        width:%3;
	//|        max-width:0;
	//|      }
	//|      #commitTable.autoLayout td.authorCol, #commitTable.autoLayout th.authorCol{
	//|        max-width:124px;
	//|      }
	|      #commitTable tr.commit :nth-child(2){
	|        max-width:var(--descriptionMaxWidth);
	|        min-width:var(--descriptionMinWidth);
	|      }
	|      #commitTable tr.commit :first-child{
	|        min-width:%4px;
	|        box-sizing:border-box;
	|      }
	|      @media screen and (min-width: 775px) and (max-width: 850px) {
	|        #commitTable.autoLayout td.dateCol, #commitTable.autoLayout th.dateCol, #commitTable.autoLayout td.authorCol, #commitTable.autoLayout th.authorCol{
	|          max-width:100px;
	|        }
	|      }
	|      @media screen and (min-width: 700px) and (max-width: 775px) {
	|        #commitTable.autoLayout td.dateCol, #commitTable.autoLayout th.dateCol, #commitTable.autoLayout td.authorCol, #commitTable.autoLayout th.authorCol{
	|          max-width:90px;
	|        }
	|      }
	|      @media screen and (max-width: 700px) {
	|        #commitTable.autoLayout td.dateCol, #commitTable.autoLayout th.dateCol, #commitTable.autoLayout td.authorCol, #commitTable.autoLayout th.authorCol{
	|          max-width:80px;
	|        }
	|      }
	|    </style>
	|  </head>
	|  <body>
	|    <div class=""container"">
	|      <div id=""graph"" class=""graph"">
	|        <svg xmlns=""http://www.w3.org/2000/svg"" width=""%4"" height=""%5"">
	|          <g>
	|%1
	|          </g>
	|        </svg>
	|      </div>
	|      <div id=""commitTable"">
	|%2
	|      </div>
	|    </div>
	|    <script>
	|      const updateGraphPosition = () => {
	|        const colHeadersElem = document.getElementById('tableColHeaders');
	|        const headerHeight = colHeadersElem !== null ? colHeadersElem.clientHeight + 1 : 0;
	|        const graphElem = document.getElementById('graph');
	|        graphElem.style.top = headerHeight;
	|      }
	|
	|      const setMaxColumnWidth = () => {
	|        const graphElem = document.getElementById('graph');
	|        document.documentElement.style.setProperty('--descriptionMaxWidth',
	|          ((window.innerWidth - graphElem.clientWidth) * 0.7) + 'px');
	|        document.documentElement.style.setProperty('--descriptionMinWidth',
	|          ((window.innerWidth - graphElem.clientWidth) * 0.3) + 'px');
	|      }
	|
	|      // Изменение ширины колонки 'Описание' при изменении размера окна
	|      window.addEventListener('resize', () => {
	|        setMaxColumnWidth();
	|      });
	|
	|      setMaxColumnWidth();
	|      updateGraphPosition();
	|    </script>
	|  </body>
	|</html>";
	
КонецФункции

Функция ДоступныйЦвет(Начало, ДоступныеЦвета)
	
	Для Сч = 0 По ДоступныеЦвета.Количество() - 1 Цикл
		Если Начало > ДоступныеЦвета[Сч] Тогда
			Возврат Сч;
		КонецЕсли;
	КонецЦикла;
	
	ДоступныеЦвета.Добавить(0);
	Возврат ДоступныеЦвета.Количество() - 1;
	
КонецФункции

Функция Высота(Точки, Настройки)
	
	Высота = Точки.Количество() * Настройки.Сетка.Y
		+ Настройки.Сетка.ОтступY
		- Настройки.Сетка.Y / 2;
	
	Возврат Формат(Высота, "ЧДЦ=0; ЧГ=0");
	
КонецФункции

Функция Ширина(Точки, Настройки)
	
	X = 0;
	
	Для каждого Точка Из Точки Цикл
		
		Позиция = Git_ГрафТочка.СледующаяПозиция(Точка);
		Если Позиция.X > X Тогда
			X = Позиция.X;
		КонецЕсли;
		
	КонецЦикла;
	
	Ширина = 2 * Настройки.Сетка.ОтступX
		+ (X - 1) * Настройки.Сетка.X;

	Возврат Формат(Ширина, "ЧДЦ=0; ЧГ=0");
		
КонецФункции

Функция ДатаКоммита(ДатаКоммита)
	
	Возврат Формат('19700101' + ДатаКоммита / 1000,
		"ДФ='д МММ гггг чч:мм'");
	
КонецФункции

#КонецОбласти
