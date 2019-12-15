drop schema if exists fm_db;
create schema fm_db default character set utf8;
use fm_db;

SET GLOBAL log_bin_trust_function_creators = 1;

drop table if exists sex_insertion_time;
drop table if exists family_tree;
drop table if exists family_items;
drop table if exists family_members;
drop table if exists item_belongings;
drop table if exists sex;

drop procedure if exists insert_into_family_items;

create table sex_insertion_time
(
    id          int         not null auto_increment,
    insert_time varchar(45) not null,
    primary key (id)

);

create table family_tree
(
    id                 int         not null auto_increment,
    name               varchar(45) not null,
    surname            varchar(45) not null,
    birth_date         date        not null,
    death_date         date        not null,
    birth_place        varchar(45) not null,
    death_place        varchar(45) not null,
    credit_card_number varchar(45) not null,
    family_members_id  int         not null,
    sex_id             int         not null,
    family_tree_id     int         not null,
    family_tree_sex_id int         not null,
    primary key (id)
);

create table family_items
(
    id                int         not null auto_increment,
    name              varchar(45) not null,
    approximate_price int         not null,
    max_price         int         not null,
    min_price         int         not null,
    catalog_code      int         not null,
    primary key (id)

);

create table family_members
(
    id            int         not null auto_increment,
    name          varchar(45) not null,
    surname       varchar(45) not null,
    birth_date    date        not null,
    death_date    date        not null,
    birth_place   varchar(45) not null,
    death_place   varchar(45) not null,
    marriage_date date        not null,
    sex_id        int         not null,
    primary key (id)
);

create table item_belongings
(
    family_tree_id  int not null,
    family_items_id int not null,
    primary key (family_items_id, family_tree_id)
);

create table sex
(
    id  int         not null auto_increment,
    sex varchar(45) not null,
    primary key (id)
);

insert into family_items(name, approximate_price, max_price, min_price, catalog_code)
values ('Mona Lisa', 20000, 34000, 15000, 3);
insert into family_items(name, approximate_price, max_price, min_price, catalog_code)
values ('Ancient chair', 1000, 1400, 900, 1);
insert into family_items(name, approximate_price, max_price, min_price, catalog_code)
values ('Mona Lisa', 20000, 34000, 15000, 3);

insert into family_tree (name, surname, birth_date, death_date, birth_place, death_place, credit_card_number,
                         family_members_id, sex_id, family_tree_id, family_tree_sex_id)
values ('Peter', 'Quill', '1970-01-01', '2270-03-01', 'USA', 'Nova', '1111222233334444', 2, 2, 2, 2);

insert into family_members(name, surname, birth_date, death_date, birth_place, death_place, marriage_date, sex_id)
values ('Petro', 'Petrenko', '1993-11-11', '2193-11-11', 'Lviv', 'Lviv', '2020-11-11', 2);

insert into item_belongings(family_tree_id, family_items_id)
VALUES (1, 1);

insert into sex(sex)
    value ('Woman');
insert into sex(sex)
    value ('Man');
insert into sex(sex)
    value ('Man');

-- PROCEDURES --
DELIMITER //

CREATE PROCEDURE logging()
BEGIN
    select concat(CURDATE(), " ", CURRENT_TIME()) into @t;
    insert into sex_insertion_time(insert_time) values (@t);
END //

CREATE PROCEDURE create_table()
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE a CHAR(45);
    DECLARE b int;
    DECLARE c int;
    DECLARE d int;
    DECLARE e int;
    DECLARE cur CURSOR FOR SELECT name, approximate_price, max_price, min_price, catalog_code FROM family_items;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TABLE IF EXISTS family_items_new;

    CREATE TABLE family_items_new
    (

        id                int         not null auto_increment,
        name              varchar(45) not null,
        approximate_price int         not null,
        max_price         int         not null,
        min_price         int         not null,
        catalog_code      int         not null,
        primary key (id)
    );

    OPEN cur;
    read_loop:
    LOOP
        FETCH cur INTO a, b, c, d, e;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO family_items_new(name, approximate_price, max_price, min_price, catalog_code)
        VALUES (a, b, c, d, e);
    END LOOP;

    CLOSE cur;

END //

create procedure insert_into_family_items()
begin
    declare max_counter int unsigned default 10;
    declare counter int unsigned default 0;
    declare random_number int unsigned default 0;
    declare noname varchar(45) default "Noname";

    while counter <= max_counter
        do
            set random_number = FLOOR(RAND() * (1000 - 1 + 1) + 1);
            if not exists(select id from family_items where name = concat(noname, random_number)) then
                insert into family_items(name, approximate_price, max_price, min_price, catalog_code)
                values (concat(noname, random_number), 1, 1, 1, 1);
                set counter = counter + 1;
            end if;
        end while;
end //

DELIMITER ;

-- FUNCTIONS --
DELIMITER //

CREATE FUNCTION select_firs_letters(id int)
    RETURNS VARCHAR(45)
BEGIN
    DECLARE n CHAR(45);
    DECLARE s CHAR(45);
    select LEFT(name, 1), LEFT(surname, 1)
    INTO n, s
    from family_tree
    where family_tree.id = id
    LIMIT 1;
    return concat(n, s);
END //

CREATE FUNCTION select_key(id INT)
    RETURNS VARCHAR(45)
BEGIN
    select birth_place, surname
    into @b, @s
    from family_tree
    where family_tree.id = id
    LIMIT 1;
    return concat(@b, @s);
END //

DELIMITER ;

-- TRIGGERS --
DELIMITER //

CREATE TRIGGER jurnal
    BEFORE INSERT
    ON sex
    FOR EACH ROW
BEGIN
    CALL logging();
END //

create trigger items_price_constraint
    before insert
    on family_items
    for each row
begin
    if (new.max_price < new.min_price) then
        signal sqlstate '45000' set message_text = 'Minimal price can not be bigger that maximal price';
    end if;
end //

create trigger card_format
    before insert
    on family_tree
    for each row
begin
    if (LEFT(new.credit_card_number, 4) REGEXP '[^0-9]') != 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "1111" !';
    elseif (MID(REPLACE(new.credit_card_number, " ", "0"), 3, 5) REGEXP '[0]') = 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "1 2" !';
    elseif (MID(REPLACE(new.credit_card_number, " ", "0"), 4, 9) REGEXP '[^0-9]') != 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "2222" !';
    elseif (MID(REPLACE(new.credit_card_number, " ", "0"), 8, 10) REGEXP '[0]') = 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "2 3" !';
    elseif (MID(REPLACE(new.credit_card_number, " ", "0"), 9, 14) REGEXP '[^0-9]') != 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "3333" !';
    elseif (MID(REPLACE(new.credit_card_number, " ", "0"), 14, 15) REGEXP '[0]') = 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "3 4" !';
    elseif (RIGHT(new.credit_card_number, 4) REGEXP '[^0-9]') != 0 then
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 30001, MESSAGE_TEXT = 'Credit card doesn`t match pattern 2 "4444" !';
    end if;
end
//

DELIMITER ;
