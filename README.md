# apex-comments

![apexcommentimg](https://user-images.githubusercontent.com/100072414/161127400-6822527c-df3c-46ee-b11d-206db1d3a298.jpg)

Oracle Application Express - Comments plugin

This plug-in helps to build a comment region to application express developers.

Minimum requirement: Oracle Application Expresss 19.1

This plug-in uses the <a href="https://viima.github.io/jquery-comments/" rel="nofollow">Viima jquery-comments</a> and the <a href="https://github.com/yuku/textcomplete" rel="nofollow">YUKU textcomplete</a> and the <a href="https://momentjs.com/" rel="nofollow">Moment.js</a> library.

# setup

You can check each setup in my downloadable <a href="https://github.com/baldogiRichard/plug-in-site" rel="nofollow">Sample Application: APEX Plug-ins by Richard Baldogi</a>

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

<pre><code>    function(config) {
    &nbsp;&nbsp;&nbsp;config.profilePictureURL = 'f?p=&APP_ID.:&APP_PAGE_ID.:&APP_SESSION.:APPLICATION_PROCESS=GETIMAGE:::FILE_ID:' + apex.item('P3_PPURL_ID').getValue();
    &nbsp;&nbsp;&nbsp;config.replyText = 'Válasz';
    &nbsp;&nbsp;&nbsp;config.enableHashtags = true;
    &nbsp;&nbsp;&nbsp;config.editText = 'Szerkesztés';
    &nbsp;&nbsp;&nbsp;config.deleteText = 'Törlés';
    &nbsp;&nbsp;&nbsp;config.saveText = 'Mentés';
    &nbsp;&nbsp;&nbsp;config.hideRepliesText = 'Elrejtés';
    &nbsp;&nbsp;&nbsp;config.viewAllRepliesText = 'Összes válasz mutatása (__replyCount__)';
    &nbsp;&nbsp;&nbsp;config.roundProfilePictures = true;
    &nbsp;&nbsp;&nbsp;config.timeFormatter = function(time) {
    &nbsp;&nbsp;&nbsp;return moment(time).format('MMMM Do YYYY, h:mm:ss a');
    };

    &nbsp;&nbsp;&nbsp;return config;
    }
</code></pre>


For more options please check the <a href="https://viima.github.io/jquery-comments/" rel="nofollow">Viima jquery-comments</a> API.

# Display image from BLOB column

Images can be displayed from BLOB columns by using/defining an Application Process in the Shared Components

<u>Application Process example:</u>

<pre><code>
begin
    for c1 in (select *
                 from apex_comments_users
                where empno = :FILE_ID) loop
        --
        sys.htp.init;
        sys.owa_util.mime_header( c1.profile_picture_mimetype, FALSE );
        sys.htp.p('Content-length: ' || sys.dbms_lob.getlength( c1.profile_picture));
        sys.htp.p('Content-Disposition: attachment; filename="' || c1.profile_picture_filename || '"' );
        sys.htp.p('Cache-Control: max-age=3600');  -- tell the browser to cache for one hour, adjust as necessary
        sys.owa_util.http_header_close;
        sys.wpg_docload.download_file( c1.profile_picture );
     
        apex_application.stop_apex_engine;
    end loop;
end
</code></pre>

<u>Query example:</u>

<pre><code>
select   ID_COLUMN      as comment_id
       , PARENT_ID      as reply_id
       , CONTENT_STR    as comment_text
       , CREATED        as created_date
       , MODIFIED       as modified_date
       , CREATED_BY     as username
       , case when prof_pic_url is null
                then null
              else 
                'f?p=&APP_ID.:&APP_PAGE_ID.:&APP_SESSION.:APPLICATION_PROCESS=GETIMAGE:::FILE_ID:' || PROF_PIC_URL
         end as prof_pic_url_display
       , case when CREATED < sysdate - 2
              then 1
              else 0
         end as new_comment
       , PROF_PIC_URL as prof_pic_url_save
from apex_comments
</code><pre>


#

License MIT
