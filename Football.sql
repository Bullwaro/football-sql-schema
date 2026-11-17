/*
ФИО:        Тимофеев Кирилл Сергеевич
Вариант:    25

Условие задачи:
    Описание информационной системы чемпионата по футболу.
    Включает в себя: игроков, команды, страны или клубы,
    сетку игр, таблицы результатов.
    Описание игроков включает: фамилию, имя, дату рождения, страну.
    Описание команд включает в себя перечень игроков
    и их номеров и амплуа в команде.
    Также команда связана со страной или клубом (что-то одно).
    Страна характеризуется кратким и полным названием и регионом
    (Азия, Европа, Африка, Австралия и Океания, Северная Америка,
    Южная и Латинская Америка).
    Клуб характеризуется кратким и полным названиями.
    Сетка игр включает: две команды, участвующие во встрече, день, время
    и место проведения встречи, уровень игры с указанием названия подгруппы
    для группового раунда (групповой раунд, 1/8 финала, ¼ финала, полуфинал,
    финал, игра за 3-е место). Таблица результатов команд включает для каждого
    элемента сетки игр: счет (включая возможные послематчевые пенальти)
    и кол-во очков для группового этапа. Таблица результатов голов включает:
    кто и из какой команды, в каком матче (элемент сетки),
    на какой минуте забил гол. Таблица результатов нарушений включает,
    кто и из какой команды, в каком матче, какую карточку получил
    и в какое время. Игроки не могут менять команды.
*/

CREATE TABLE countries (

    country_id serial,
    country_shortname varchar(64) NOT NULL,
    country_fullname varchar(64) NOT NULL,

    --кодировка региона одной буквой
    country_region char NOT NULL,
    CHECK (country_region IN ('А', 'Е', 'Ф', 'О', 'С', 'Ю')),
    /*
    А — Азия
    Е — Европа
    Ф — Африка
    О — Австралия и Океания
    С — Северная Америка
    Ю — Южная и Латинская Америка
    */

    PRIMARY KEY (country_id)
);

CREATE TABLE clubs (

    club_id serial,
    short_name varchar(64) NOT NULL,
    full_name varchar(64) NOT NULL,

    PRIMARY KEY (club_id)
);

CREATE TABLE players (

    player_id serial,
    first_name varchar(64) NOT NULL,
    last_name varchar(64) NOT NULL,

    birth_date date NOT NULL,
    country_id integer REFERENCES countries (country_id),

    PRIMARY KEY (player_id)
);

CREATE TABLE teams (

    team_id serial,
    country_id integer REFERENCES countries (country_id),
    club_id integer REFERENCES clubs (club_id),
    CHECK (
        (country_id IS NULL OR club_id IS NULL)
        AND
        (country_id IS NOT NULL OR club_id IS NOT NULL)
    ),

    PRIMARY KEY (team_id)
);

CREATE TABLE team_players (

    team_id integer NOT NULL REFERENCES teams,
    player_id integer NOT NULL UNIQUE REFERENCES players,
    player_number smallint NOT NULL,
    player_role varchar(64) NOT NULL,

    UNIQUE (team_id, player_number),
    PRIMARY KEY (team_id, player_id)
);

CREATE TABLE bracket (
    match_id serial,
    team_1_id integer NOT NULL REFERENCES teams (team_id),
    team_2_id integer NOT NULL REFERENCES teams (team_id),

    match_day date NOT NULL,
    match_time time NOT NULL,
    match_level varchar(64) NOT NULL,
    group_name varchar(64),
    match_place varchar(64) NOT NULL,

    CHECK (team_1_id != team_2_id),
    CHECK (
        match_level IN (
            'Групповой раунд',
            '1/8 финала',
            '1/4 финала',
            'Полуфинал',
            'Финал',
            'Матч за 3-е место'
        )
    ),
    CHECK (
        (match_level = 'Групповой раунд' AND group_name IS NOT NULL)
        OR
        (match_level != 'Групповой раунд' AND group_name IS NULL)
    ),
    PRIMARY KEY (match_id)
);

CREATE TABLE team_results (

    match_id integer NOT NULL REFERENCES bracket (match_id),

    team_1_score smallint NOT NULL,
    team_1_penalties smallint,

    team_2_score smallint NOT NULL,
    team_2_penalties smallint,

    team_1_group_score smallint NOT NULL,
    team_2_group_score smallint NOT NULL,

    CHECK (
        team_1_score >= 0
        AND team_2_score >= 0
        AND team_1_group_score >= 0
        AND team_2_group_score >= 0
    ),
    CHECK (
        (team_1_penalties IS NULL OR team_1_penalties >= 0)
        AND
        (team_2_penalties IS NULL OR team_2_penalties >= 0)
    ),
    PRIMARY KEY (match_id)
);

CREATE TABLE goals (

    match_id integer NOT NULL REFERENCES bracket (match_id),
    player_id integer NOT NULL REFERENCES players (player_id),
    team_id integer NOT NULL REFERENCES teams (team_id),
    goal_on_minute smallint NOT NULL,

    CHECK (goal_on_minute >= 0),
    FOREIGN KEY (team_id, player_id)
    REFERENCES team_players (team_id, player_id)
);

CREATE TABLE fouls (

    match_id integer NOT NULL REFERENCES bracket (match_id),
    team_id integer NOT NULL,
    player_id integer NOT NULL,

    foul_time time NOT NULL,
    card_colour char NOT NULL,  --кодировка цвета карточки одной буквой
    CHECK (card_colour IN ('К', 'Ж')),

    FOREIGN KEY (team_id, player_id)
    REFERENCES team_players (team_id, player_id)
);
