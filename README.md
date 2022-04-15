# apex-comments

![apexcommentimg](https://user-images.githubusercontent.com/100072414/161127400-6822527c-df3c-46ee-b11d-206db1d3a298.jpg)

Oracle Application Express - Comments plugin

This plug-in helps to build a comment region to application express developers.

Minimum requirement: Oracle Application Expresss 19.1

This plug-in uses the <a href="https://viima.github.io/jquery-comments/" rel="nofollow">Viima jquery-comments</a> and the <a href="https://github.com/yuku/textcomplete" rel="nofollow">YUKU textcomplete</a> and the <a href="https://momentjs.com/" rel="nofollow">Moment.js</a> library.

# setup

The following attributes must be specified in order to fulfill the JSON which will display the comments in the region.

<u>Query example:</u>

<pre><code>select   id_column      as id
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, parent_id      as parent
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, comment        as content
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, created_date   as created
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, modified_date  as modified
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, name           as fullname
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, prof_pic_url   as profile_picture_url
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, case when created_date &lt; sysdate - 2
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;then 1
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;else 0
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end as is_new
from comments_table</code></pre>

<u>JSON example:</u>

<pre><code>{
id: "c2",
parent: "c1",
content: "Welcome!",
created: "2022-03-31T17:57:34Z",
modified: "2022-04-31T17:27:14Z",
fullname: "RICHARDB DEVELOPER",
profile_picture_url: "https://www.someprofilepicture.com/profpic1.jpg",
is_new: true / false
}</code></pre>

<b>Settings</b>

![image](https://user-images.githubusercontent.com/100072414/163565918-6c91104e-1aab-49d0-b365-5f33728c65c5.png)

<b>Pinging users</b>

<u>Query example:</u>

<pre><code>select   empno                                  as ID 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, ename                                  as USERNAME
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, ename || ' ' || job                    as NAME 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, ename || '.' || job || '@company.com'  as EMAIL
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, pp_url                                 as PROFILE_PICTURE_URL
from emp;</code></pre>

![image](https://user-images.githubusercontent.com/100072414/163566318-a0c7bf22-f848-4e63-9f5c-b14494f2ed81.png)

<b>Filter column/item - multiple comments for different records</b>

Developers can specify a source id column if for example: The comments should be related to different records in another table
then they must specify a column which will be filled and an item where the column value must be returned.

Also the query have to be extended with a where clause which filters the comments.

![image](https://user-images.githubusercontent.com/100072414/163567076-6566d083-98d6-4e18-9c6a-38ed2ce81347.png)

<u>Query example:</u>

<pre><code>select   id_column      as id
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, parent_id      as parent
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, comment        as content
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, created_date   as created
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, modified_date  as modified
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, name           as fullname
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, prof_pic_url   as profile_picture_url
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, case when created_date &lt; sysdate - 2
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;then 1
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;else 0
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;end as is_new
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;, column_filter
from comments_table
where column_filter = :P_FILTER_ITEM</code></pre>

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

For more options please check the <a href="https://viima.github.io/jquery-comments/" rel="nofollow">Viima jquery-comments</a> API.

#

License MIT
