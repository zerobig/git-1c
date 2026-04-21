# 1С Предприятие. Работа с Git репозиторием

## Мотивация

Сначала для одного из проектов мне потребовалась минимальная поддержка работы с Git из 1С Предприятия. Потом выяснилось, что построение графа ни разу не тривиальная задача и народ по этой теме умудряется писать докторские дисертации:

- [Liu Liu](https://www.dolthub.com/blog/2024-08-07-drawing-a-commit-graph/)
- [Pierre Vigier](https://pvigier.github.io/2019/05/06/commit-graph-drawing-algorithms.html)
- [Dan Wentworth](https://www.codebasehq.com/blog/building-commit-graphs)

И я, как всегда, увлёкся.

## Описание

Пока что расширение позволяет всего лишь считывать информацию о логах git репозитория и отображать их в виде графа:

![image](https://github.com/zerobig/git-1c/blob/main/docs/static/screenshot_1.png)

## Как запустить

Скачать файл с расширением cfe из раздела [Releases](https://github.com/zerobig/git-1c/releases) и установить это расширение в свою базу данных;

## Идеи по дальнейшему развитию (roadmap)

- [x] чтение логов;
- [x] создание графа коммитов;
- [ ] развитие отображение информации в графе:
  - [ ] теги
  - [ ] ветви
  - [ ] remote ветви
  - [ ] незакоммиченные изменения
- [ ] выполнение основных команд Git:
  - [ ] add
  - [ ] commit
  - [ ] push
  - [ ] pull
  - [ ] branch
  - [ ] checkout
  - [ ] stash
- [ ] написание тестов
- [ ] создание документации

## Благодарности

[1CFilesConverter](https://github.com/arkuznetsov/1CFilesConverter) - давно пользуюсь этими скриптами. Очень помогают.
