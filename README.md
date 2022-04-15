# apex-comments

![apexcommentimg](https://user-images.githubusercontent.com/100072414/161127400-6822527c-df3c-46ee-b11d-206db1d3a298.jpg)

Oracle Application Express - Comments plugin

This plug-in helps to build a comment region to application express developers.

Minimum requirement: Oracle Application Expresss 19.1

This plug-in uses the <a href="https://viima.github.io/jquery-comments/" rel="nofollow">Viima jquery-comments</a> and the <a href="https://github.com/yuku/textcomplete" rel="nofollow">YUKU textcomplete</a> and the <a href="https://momentjs.com/" rel="nofollow">Moment.js</a> library.

# setup

The following attributes must be specified in order to fulfill the JSON which will display the comments in the region.

Query example:

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

JSON example:

{
content: "Welcome!"
created: "2022-03-31T17:57:34Z"
created_by_current_user: true / false
fullname: "RICHARDB DEVELOPER"
parent: "c1"
id: "c2"
is_new: true
profile_picture_url: "https://www.someprofilepicture.com/profpic1.jpg"
}



#

License MIT
