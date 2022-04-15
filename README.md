# apex-comments

![apexcommentimg](https://user-images.githubusercontent.com/100072414/161127400-6822527c-df3c-46ee-b11d-206db1d3a298.jpg)

Oracle Application Express - Comments plugin

This plug-in helps to build a comment region to application express developers.

Minimum requirement: Oracle Application Expresss 19.1

This plug-in uses the <a href="https://viima.github.io/jquery-comments/" rel="nofollow">Viima jquery-comments</a> and the <a href="https://github.com/yuku/textcomplete" rel="nofollow">YUKU textcomplete</a> and the <a href="https://momentjs.com/" rel="nofollow">Moment.js</a> library.

# setup

The following attributes must be specified in order to fulfill the JSON which will display the comments in the region.

<u>Query example:</u>

select   id_column      as id
       , parent_id      as parent
       , comment        as content
       , created_date   as created
       , modified_date  as modified
       , name           as fullname
       , prof_pic_url   as profile_picture_url
       , case when created_date < sysdate - 2
              then 1
              else 0
         end as is_new
from comments_table

<u>JSON example:</u>

{
id: "c2",
parent: "c1",
content: "Welcome!",
created: "2022-03-31T17:57:34Z",
modified: "2022-04-31T17:27:14Z",
fullname: "RICHARDB DEVELOPER",
profile_picture_url: "https://www.someprofilepicture.com/profpic1.jpg",
is_new: true / false
}

<b>Settings</b>

![image](https://user-images.githubusercontent.com/100072414/163565918-6c91104e-1aab-49d0-b365-5f33728c65c5.png)

<b>Pinging users</b>

<u>Query example:</u>

select   empno                                  as ID 
       , ename                                  as USERNAME
       , ename || ' ' || job                    as NAME 
       , ename || '.' || job || '@company.com'  as EMAIL
       , pp_url                                 as PROFILE_PICTURE_URL
from emp;

![image](https://user-images.githubusercontent.com/100072414/163566318-a0c7bf22-f848-4e63-9f5c-b14494f2ed81.png)

<b>Filter column/item - multiple comments for different records</b>

Developers can specify a source id column if for example: The comments should be related to different records in another table
then they must specify a column which will be filled and an item where the column value must be returned.

Also the query have to be extended with a where clause which filters the comments.

![image](https://user-images.githubusercontent.com/100072414/163567076-6566d083-98d6-4e18-9c6a-38ed2ce81347.png)

<u>Query example:</u>

select   id_column      as id
       , parent_id      as parent
       , comment        as content
       , created_date   as created
       , modified_date  as modified
       , name           as fullname
       , prof_pic_url   as profile_picture_url
       , case when created_date < sysdate - 2
              then 1
              else 0
         end as is_new
       , column_filter
from comments_table
where column_filter = :P_FILTER_ITEM

<b>Customizing the comment region</b>

Developers can customize their region by specifying a function in the Javascript Initialization Code section

Example:

    function(config) {
    config.replyText = 'Válasz';
    config.enableHashtags = true;
    config.editText = 'Szerkesztés';
    config.deleteText = 'Törlés';
    config.saveText = 'Mentés';
    config.hideRepliesText = 'Elrejtés';
    config.viewAllRepliesText = 'Összes válasz mutatása (__replyCount__)';
    config.roundProfilePictures = true;
    config.timeFormatter = function(time) {
    return moment(time).format('MMMM Do YYYY, h:mm:ss a');
    };

    return config;
    }

#

License MIT
