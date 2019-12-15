-- Stored procedure 2 --
use fm_db;
call insert_into_family_items();
select *
from family_items;

-- Stored procedure 3 --
use fm_db;
call create_table();
select *
from family_items_new;

-- Stored function 1 --
use fm_db;
select name, surname, birth_date, select_firs_letters(family_tree.id)
from family_tree;
-- Stored function 2 --
use fm_db;
select name, surname, birth_date, select_key(family_members.id)
from family_members;

-- Trigger 1 --
use fm_db;
insert into family_tree (name, surname, birth_date, death_date, birth_place, death_place, credit_card_number,
                         family_members_id, sex_id, family_tree_id, family_tree_sex_id)
values ('Peter', 'Quill', '1970-01-01', '2270-03-01', 'USA', 'Nova', '1111-2221 3333 4444', 2, 2, 2, 2);
select *
from family_tree;

-- Trigger 2 --
use fm_db;
insert into family_items(name, approximate_price, max_price, min_price, catalog_code)
VALUES ('Aladine lamp', 200, 100, 220, 3);
select *
from family_items;

-- Trigger 3 --
use fm_db;
insert into sex(sex)
    value ('Man');
select *
from sex_insertion_time;
