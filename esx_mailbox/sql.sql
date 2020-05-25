create table mail
(
    id       int auto_increment
        primary key,
    titel    text not null,
    text     text not null,
    footer   text not null,
    gesendet date not null,
    autor    text not null,
    unread   int  not null,
    dbid     int  null
)
    charset = utf8mb4;


create table mail_setting
(
    id    int auto_increment
        primary key,
    `key` text not null,
    value text not null,
    dbid  int  null
)
    charset = utf8mb4;

INSERT INTO mail_setting (id, `key`, value, dbid) VALUES 
	
(1, 'title', 'Police', 1),
(2, 'title', 'Armory', 1),
(3, 'title', 'Cardealer', 1),
(4, 'title', 'Mechanic', 1);

;