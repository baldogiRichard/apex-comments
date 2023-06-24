-- =============================================================================
--
--  Created by Richard Baldogi
--
--  This plug-in provides a region where you can write comments.
--
--  License: MIT
--
--  GitHub: https://github.com/baldogiRichard/apex-comments
--
-- =============================================================================

--This procedure was created to split strings that's length is over 32K
procedure splitJSON(p_json in clob,
                    p_varname in varchar2,
                    p_splitter in number)
is
    l_chunks_cnt number;
    l_from number := 1;
begin
    l_chunks_cnt := ceil(length(p_json) / p_splitter);
    apex_javascript.add_inline_code (p_code => 'var ' || p_varname || ' = "";');
    for i in 1..l_chunks_cnt loop
        apex_javascript.add_inline_code (p_code => p_varname || ' += "' || 
                                                   apex_escape.json(p_string => substr(p_json,l_from,p_splitter))
                                                   || '";');    
        l_from := (i * p_splitter) + 1;
    end loop;
end splitJSON;

--a boolean function that converts TRUE or FALSE string values into boolean values
function get_boolean(p_bool in varchar2)
return boolean
as
begin
    return case when upper(p_bool) = 'TRUE'
                    then true
                when upper(p_bool) = 'FALSE'
                    then false
                when p_bool = 1
                    then true
                when p_bool = 0
                    then false
                when p_bool = '1'
                    then true
                when p_bool = '0'
                    then false
                end;
end get_boolean;

--get pinginglist data
function get_pinginglist_data
   (  p_region_pinging             in apex_plugin.t_region
   )
return clob
as
    --pinging source
    l_context                           apex_exec.t_context;
    l_context_pinging                   apex_exec.t_context;
    l_pinging_list                      p_region_pinging.attribute_15%type := p_region_pinging.attribute_15;

    --pings variables
    l_pinging_id_val                    number;
    l_pinging_name_val                  varchar2(100);
    l_pinging_username_val              varchar2(100);
    l_pinging_email_val                 varchar2(200);
    l_prof_pics_url_val                 varchar2(32767);

    --pings variables 2
    l_pinging_id                        pls_integer;
    l_pinging_name                      pls_integer;
    l_pinging_username                  pls_integer;
    l_pinging_email                     pls_integer;
    l_prof_pics_url                     pls_integer;

    --pinging and editing is enabled
    l_pinging                           boolean := (p_region_pinging.attribute_14 = 'ENABLE');

    --user infos
    l_fullname              varchar2(100);
    l_user_profile_picture  varchar2(32767);

    --clob
    l_clob_result clob;

begin
    if l_pinging then

        l_context_pinging := apex_exec.open_query_context
            ( p_location        => apex_exec.c_location_local_db
            , p_sql_query       => l_pinging_list
            , p_total_row_count => true
            );

        l_pinging_id        := apex_exec.get_column_position(l_context_pinging, 'ID');
        l_pinging_name      := apex_exec.get_column_position(l_context_pinging, 'NAME');
        l_pinging_username  := apex_exec.get_column_position(l_context_pinging, 'USERNAME');
        l_pinging_email     := apex_exec.get_column_position(l_context_pinging, 'EMAIL');
        l_prof_pics_url     := apex_exec.get_column_position(l_context_pinging, 'PROFILE_PICTURE_URL');

        apex_json.initialize_clob_output;

        apex_json.open_array;

        while apex_exec.next_row(l_context_pinging) 
        loop

            l_pinging_id_val       := apex_exec.get_number   (    l_context_pinging, l_pinging_id        );
            l_pinging_name_val     := apex_exec.get_varchar2 (    l_context_pinging, l_pinging_name      );
            l_pinging_username_val := apex_exec.get_varchar2 (    l_context_pinging, l_pinging_username  );
            l_pinging_email_val    := apex_exec.get_varchar2 (    l_context_pinging, l_pinging_email     );
            l_prof_pics_url_val    := apex_exec.get_varchar2 (    l_context_pinging, l_prof_pics_url     );

            --load userinfos to variables which will be used later in the functionalities JSON
            if l_pinging_username_val = v('APP_USER') then

                l_fullname              := l_pinging_name_val;
                l_user_profile_picture  := l_prof_pics_url_val;
                
            end if;

            apex_json.open_object;

                apex_json.write('id'                     , l_pinging_id_val    );
                apex_json.write('fullname'               , l_pinging_name_val  );
                apex_json.write('email'                  , l_pinging_email_val );
                apex_json.write('profile_picture_url'    , l_prof_pics_url_val );

            apex_json.close_object;

        end loop;

        apex_json.close_array;

        l_clob_result := apex_json.get_clob_output;

        apex_json.free_output;

        apex_exec.close(l_context);

    end if;

    return l_clob_result;
end get_pinginglist_data;

--get functionalities
function get_functionalities
   (  p_region_functionalities             in apex_plugin.t_region)
return clob 
as
    --user infos
    l_fullname              varchar2(100);
    l_user_profile_picture  varchar2(32767);

    --enable deleting with replies
    l_enable_delete                     boolean := (p_region_functionalities.attribute_19 = 'ENABLE');
    l_enable_delete_w_replies           boolean := (p_region_functionalities.attribute_20 = 'ENABLE');
    
    --editing is enabled
    l_editing                           boolean := (p_region_functionalities.attribute_18 = 'ENABLE');
    l_pinging                           boolean := (p_region_functionalities.attribute_14 = 'ENABLE');

begin

    apex_json.initialize_clob_output;

    apex_json.open_object;

        --set user
        apex_json.write('youText'           , l_fullname             );
        apex_json.write('profilePictureURL' , l_user_profile_picture );

        --set functionalities
        apex_json.write('enableEditing'                    , case when l_editing                  then TRUE else FALSE end   );
        apex_json.write('enablePinging'                    , case when l_pinging                  then TRUE else FALSE end   );
        apex_json.write('enableDeleting'                   , case when l_enable_delete            then TRUE else FALSE end   );
        apex_json.write('enableDeletingCommentWithReplies' , case when l_enable_delete_w_replies  then TRUE else FALSE end   );

        --set functions to null -> function will be set in JS side
        apex_json.write('enableUpvoting' , FALSE);

        apex_json.write( p_name       => 'getComments'
                       , p_value      => ''
                       , p_write_null => true );
        apex_json.write( p_name       => 'searchUsers'                     
                       , p_value      => ''
                       , p_write_null => true );
        apex_json.write( p_name       => 'postComment'
                       , p_value      => ''
                       , p_write_null => true );
        apex_json.write( p_name       => 'deleteComment'
                       , p_value      => ''
                       , p_write_null => true );
        apex_json.write( p_name       => 'putComment'
                       , p_value      => ''
                       , p_write_null => true );

    apex_json.close_object;

    return apex_json.get_clob_output;

    apex_json.free_output;

end get_functionalities;

--get comments data
function get_comments_data
   (  p_region_comment             in apex_plugin.t_region)
return clob
as
    --region source
    l_source                            p_region_comment.source%type := p_region_comment.source;
    l_context                           apex_exec.t_context;
    l_order_by                          apex_exec.t_order_bys;

    --attributes
    l_id_col                            p_region_comment.attribute_01%type := p_region_comment.attribute_01;
    l_parent_col                        p_region_comment.attribute_02%type := p_region_comment.attribute_02;
    l_created_date_col                  p_region_comment.attribute_03%type := p_region_comment.attribute_03;
    l_modified_date_col                 p_region_comment.attribute_04%type := p_region_comment.attribute_04;
    l_content_col                       p_region_comment.attribute_05%type := p_region_comment.attribute_05;
    l_fullname_col                      p_region_comment.attribute_07%type := p_region_comment.attribute_07;
    l_profile_picture_url_col           p_region_comment.attribute_08%type := p_region_comment.attribute_08;
    l_is_new_col                        p_region_comment.attribute_11%type := p_region_comment.attribute_11;

    --query variables
    l_id_col_pos                        pls_integer;
    l_parent_col_pos                    pls_integer;
    l_created_date_col_pos              pls_integer;
    l_modified_date_col_pos             pls_integer;
    l_content_col_pos                   pls_integer;
    l_fullname_col_pos                  pls_integer;
    l_profile_picture_url_col_pos       pls_integer;
    l_is_new_col_pos                    pls_integer;

    --comments variables
    l_id_col_val                        varchar2(32767);
    l_parent_col_val                    varchar2(32767);
    l_created_date_col_val              date;
    l_modified_date_col_val             date;
    l_content_col_val                   clob;
    l_fullname_col_val                  varchar2(100);
    l_profile_picture_url_col_val       varchar2(1500);
    l_is_new_col_val                    varchar2(10);

    --order by
    l_order_bys             apex_exec.t_order_bys;
    l_order_by_column_name  apex_exec.t_column_name := l_id_col;

    --items
    l_username_item    p_region_comment.attribute_21%type := p_region_comment.attribute_21;
    l_username_meta    apex_session_state.t_value := apex_session_state.get_value(p_item => l_username_item);

    l_comments clob;

begin

     apex_exec.add_order_by(
        p_order_bys     => l_order_bys,
        p_column_name   => l_order_by_column_name,
        p_direction     => apex_exec.c_order_asc 
    );

    l_context := apex_exec.open_query_context
        ( p_location        => apex_exec.c_location_local_db
        , p_sql_query       => l_source
        , p_total_row_count => true
        , p_order_bys       => l_order_bys);

    l_modified_date_col_pos             := apex_exec.get_column_position(l_context, l_modified_date_col);
    l_parent_col_pos                    := apex_exec.get_column_position(l_context, l_parent_col);
    l_created_date_col_pos              := apex_exec.get_column_position(l_context, l_created_date_col);
    l_id_col_pos                        := apex_exec.get_column_position(l_context, l_id_col);
    l_content_col_pos                   := apex_exec.get_column_position(l_context, l_content_col);
    l_fullname_col_pos                  := apex_exec.get_column_position(l_context, l_fullname_col);
    l_profile_picture_url_col_pos       := apex_exec.get_column_position(l_context, l_profile_picture_url_col);
    l_is_new_col_pos                    := apex_exec.get_column_position(l_context, l_is_new_col);

    apex_json.initialize_clob_output;

    apex_json.open_array;

    while apex_exec.next_row(l_context) 
    loop

        apex_json.open_object;

            l_modified_date_col_val             := apex_exec.get_varchar2   ( l_context , l_modified_date_col_pos           );
            l_parent_col_val                    := apex_exec.get_varchar2   ( l_context , l_parent_col_pos                  );
            l_id_col_val                        := apex_exec.get_varchar2   ( l_context , l_id_col_pos                      );
            l_created_date_col_val              := apex_exec.get_date       ( l_context , l_created_date_col_pos            );
            l_content_col_val                   := apex_exec.get_clob       ( l_context , l_content_col_pos                 );
            l_fullname_col_val                  := apex_exec.get_varchar2   ( l_context , l_fullname_col_pos                );
            l_profile_picture_url_col_val       := apex_exec.get_varchar2   ( l_context , l_profile_picture_url_col_pos     );
            l_is_new_col_val                    := apex_exec.get_varchar2   ( l_context , l_is_new_col_pos                  );

            apex_json.write('modified'                , l_modified_date_col_val);
            apex_json.write('parent'                  , l_parent_col_val);
            apex_json.write('hasChild'                , FALSE);
            apex_json.write('id'                      , l_id_col_val);
            apex_json.write('created'                 , l_created_date_col_val);
            apex_json.write('content'                 , l_content_col_val);
            apex_json.write('fullname'                , l_fullname_col_val);
            apex_json.write('profile_picture_url'     , l_profile_picture_url_col_val);
            apex_json.write('is_new'                  , get_boolean(l_is_new_col_val));
            apex_json.write('created_by_current_user' , case when l_fullname_col_val = l_username_meta.varchar2_value
                                                              then TRUE 
                                                              else FALSE 
                                                        end);
            apex_json.write_raw('pings'               , '{}');

        apex_json.close_object;

    end loop;

    apex_json.close_array;

    l_comments := apex_json.get_clob_output;

    apex_json.free_output;

    apex_exec.close(l_context);

    return l_comments;

end get_comments_data;

function create_initialization( p_region_init  in apex_plugin.t_region
                              , p_pinging_data in clob
                              , p_comment_data in clob
                              )
return clob
as
    --region and ajax id
    l_region_id     p_region_init.static_id%type    := p_region_init.static_id;
    l_ajax_id       p_region_init.static_id%type    := apex_plugin.get_ajax_identifier;

    --items
    l_username_item    p_region_init.attribute_21%type := p_region_init.attribute_21;
    l_profilep_item    p_region_init.attribute_22%type := p_region_init.attribute_22;

    l_username_meta    apex_session_state.t_value := apex_session_state.get_value(p_item => l_username_item);
    l_profilep_meta    apex_session_state.t_value := apex_session_state.get_value(p_item => l_profilep_item);

    --pinging and editing is enabled
    l_pinging          boolean := (p_region_init.attribute_14 = 'ENABLE');

begin
    apex_json.initialize_clob_output;    

    apex_json.open_object;

        --regionid and ajax
        apex_json.write('regionId'      , l_region_id );
        apex_json.write('ajaxIdentifier', l_ajax_id   );

        --set items
        apex_json.write('userNameItem'              , l_username_item             );
        apex_json.write('ProfilePicsItem'           , l_profilep_item             );

        if l_pinging then
            apex_json.write_raw('pingingList'   ,   p_pinging_data          );
        end if;

        apex_json.write_raw('comments'          ,   p_comment_data         );

    apex_json.close_object;

    return apex_json.get_clob_output;

    apex_json.free_output;

end;

--render
function render
  ( p_region              in apex_plugin.t_region
  , p_plugin              in apex_plugin.t_plugin
  , p_is_printer_friendly in boolean
  )
return apex_plugin.t_region_render_result
as
    l_result                            apex_plugin.t_region_render_result;

    --init js
    l_init_js                           varchar2(32767)            := nvl(apex_plugin_util.replace_substitutions(p_region.init_javascript_code), 'undefined');

    --JSON variables
    l_pinging_json                      clob;
    l_functionalities_json              clob;
    l_comments_json                     clob;
    l_initialization_json               clob;

    --other variables
    l_js_varname            constant varchar2(10)   := sys.dbms_random.string('a',10);

begin

    --debug
    if apex_application.g_debug 
    then
        apex_plugin_util.debug_region
          ( p_plugin => p_plugin
          , p_region => p_region
          );
    end if;

    --creating pinging list JSON
    l_pinging_json := get_pinginglist_data(  p_region_pinging => p_region);

    --create functionalities JSON
    l_functionalities_json := get_functionalities(  p_region_functionalities => p_region);

    --creating comments JSON
    l_comments_json :=  get_comments_data( p_region_comment => p_region);

    --creating JSON for JS initialization
    l_initialization_json := create_initialization( p_region_init  => p_region
                                                   , p_pinging_data => l_pinging_json
                                                   , p_comment_data => l_comments_json);

    --split JSON
    splitJSON(p_json     => l_initialization_json,
              p_varname  => l_js_varname,
              p_splitter => 5000);
    
    --Add onload code
    apex_javascript.add_onload_code(p_code => 'COMMENTS.initialize(' || l_functionalities_json || ',' || l_js_varname || ','|| l_init_js ||');');
    
    return l_result;
end render;

--ajax
function ajax
    ( p_region in apex_plugin.t_region
    , p_plugin in apex_plugin.t_plugin 
    )
return apex_plugin.t_region_ajax_result
as
    l_return         apex_plugin.t_region_ajax_result;

    -- error handling
    l_apex_error     apex_error.t_error;

    --dummy value for setting parent id to null when deleting a comment with replies
    l_null           varchar2(1)           := null;

    --ajax values
    l_action         varchar2(1)           := apex_application.g_x01;
    l_id             varchar2(32000)       := apex_application.g_x02;
    l_parent_id      varchar2(32000)       := apex_application.g_x03;
    l_comment        clob                  := apex_application.g_x04;
    l_fullname       varchar2(200)         := apex_application.g_x05;
    l_delete_replies varchar2(10)          := apex_application.g_x06;
    l_profile_pic    varchar2(32000)       := apex_application.g_x07; 

    --attributes
    l_id_col                    p_region.attribute_01%type := p_region.attribute_01;
    l_parent_col                p_region.attribute_02%type := p_region.attribute_02;
    l_created_date_col          p_region.attribute_03%type := p_region.attribute_03;
    l_modified_date_col         p_region.attribute_04%type := p_region.attribute_04;
    l_content_col               p_region.attribute_05%type := p_region.attribute_05;
    l_fullname_col              p_region.attribute_07%type := p_region.attribute_07;
    l_profile_picture_url_col   p_region.attribute_23%type := p_region.attribute_23;

    --region source
    l_context_dml        apex_exec.t_context;
    l_context_query      apex_exec.t_context;
    l_columns            apex_exec.t_columns;
    l_filters            apex_exec.t_filters;
    l_source             p_region.source%type    := p_region.source;

    --dml operation
    l_enable_delete_w_replies  boolean                    := (p_region.attribute_20 = 'ENABLE');
    l_operation                apex_exec.t_dml_operation  := case when l_action = 'I'
                                                                    then apex_exec.c_dml_operation_insert
                                                                  when l_action = 'U'
                                                                    then apex_exec.c_dml_operation_update
                                                                  when l_action = 'D'
                                                                    then apex_exec.c_dml_operation_delete
                                                              end;

    --variables for deleting, updating replies
    l_ids_arr          apex_t_varchar2;
    l_id_col_pos       pls_integer;
    l_id_col_val       varchar2(32767);
    l_source_2         p_region.source%type;

    --variables for refreshing data
    l_pinging_json             clob;
    l_comments_json            clob;

    --new id on insert
    l_id_new varchar2(500) := 'c' || to_char(to_number(sys_guid(),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'));
begin

    --debug
    if apex_application.g_debug 
    then
        apex_plugin_util.debug_region
          ( p_plugin => p_plugin
          , p_region => p_region
          );
    end if;

    if l_action != 'R' then

        --add columns for operation UPDATE, INSERT
        if l_delete_replies != 'DELREPLIES' then

            apex_exec.add_column
                ( p_columns        => l_columns
                , p_column_name    => l_id_col
                , p_data_type      => apex_exec.c_data_type_varchar2 
                , p_is_primary_key => true
                );

            apex_exec.add_column
                ( p_columns     => l_columns
                , p_column_name => l_parent_col 
                , p_data_type   => apex_exec.c_data_type_varchar2 
                );

            apex_exec.add_column
                ( p_columns     => l_columns
                , p_column_name => l_created_date_col 
                , p_data_type   => apex_exec.c_data_type_date
                );

            apex_exec.add_column
                ( p_columns     => l_columns
                , p_column_name => l_modified_date_col 
                , p_data_type   => apex_exec.c_data_type_date
                );

            apex_exec.add_column
                ( p_columns     => l_columns
                , p_column_name => l_content_col 
                , p_data_type   => apex_exec.c_data_type_clob
                );

            apex_exec.add_column
                ( p_columns     => l_columns
                , p_column_name => l_fullname_col 
                , p_data_type   => apex_exec.c_data_type_varchar2
                );

            apex_exec.add_column
                ( p_columns     => l_columns
                , p_column_name => l_profile_picture_url_col 
                , p_data_type   => apex_exec.c_data_type_varchar2
                );

        end if;

        --delete, update replies with parent comment if enabled
        if l_action in ('U','D') 
           and l_enable_delete_w_replies 
           and l_delete_replies = 'DELREPLIES' 
        then

            if l_action = 'D' then

                apex_exec.add_column(
                      p_columns        => l_columns
                    , p_column_name    => l_id_col
                    , p_data_type      => apex_exec.c_data_type_varchar2 
                    , p_is_primary_key => true
                );

                --this function returns the IDs of the replies that should be
                --updated or deleted

                --hierarchical query
                l_source_2 := 'select * from (' || l_source || ') t' ||
                              ' start with t.' || l_id_col || ' = ''' || l_id ||
                              ''' connect by prior t.' || l_id_col || ' = ' || l_parent_col;

                --open query context
                l_context_query := apex_exec.open_query_context
                    ( p_location        => apex_exec.c_location_local_db
                    , p_sql_query       => l_source_2
                    , p_total_row_count => true
                    );

                l_id_col_pos   := apex_exec.get_column_position(l_context_query, l_id_col);

                apex_string.push( l_ids_arr , l_id );

                --loop context
                while apex_exec.next_row(l_context_query) 
                loop
                    l_id_col_val  := apex_exec.get_varchar2 ( l_context_query , l_id_col_pos );
                    apex_string.push(l_ids_arr, l_id_col_val);
                end loop;

                apex_exec.close(l_context_query);

                apex_exec.add_filter(
                    p_filters     => l_filters,
                    p_filter_type => apex_exec.c_filter_in,
                    p_column_name => l_id_col,
                    p_values      => l_ids_arr
                );

            end if;

            if l_action = 'U' then

                apex_exec.add_filter(
                    p_filters     => l_filters,
                    p_filter_type => apex_exec.c_filter_eq,
                    p_column_name => l_parent_col,
                    p_value       => l_parent_id 
                );

            end if;

            l_context_query := apex_exec.open_query_context
                ( p_location        => apex_exec.c_location_local_db
                , p_sql_query       => l_source
                , p_total_row_count => true
                , p_filters         => l_filters
                , p_columns         => l_columns
                );

            l_context_dml := apex_exec.open_local_dml_context
                ( p_sql_query             => l_source
                , p_columns               => l_columns
                , p_query_type            => apex_exec.c_query_type_sql_query
                , p_lost_update_detection => apex_exec.c_lost_update_none
                );

            while apex_exec.next_row(p_context => l_context_query) 
            loop
     
                apex_exec.add_dml_row(
                      p_context          => l_context_dml
                    , p_operation        => l_operation     
                    );

                apex_exec.set_values(
                      p_context         => l_context_dml
                    , p_source_context  => l_context_query 
                    );


                if l_action = 'U' then

                    apex_exec.set_value(
                      p_context        => l_context_dml
                    , p_column_name    => l_parent_col
                    , p_value          => l_null
                    );

                end if;

            end loop;

            apex_exec.execute_dml(
                  p_context           => l_context_dml
                , p_continue_on_error => false
            );

        end if;

        --prepare and execute dml -- delete, update current comment
        if l_action in ('U','D') and l_delete_replies != 'DELREPLIES' then

            apex_exec.add_filter(
                p_filters     => l_filters,
                p_filter_type => apex_exec.c_filter_eq,
                p_column_name => l_id_col,
                p_value       => l_id 
            );

            l_context_query := apex_exec.open_query_context
                ( p_location        => apex_exec.c_location_local_db
                , p_sql_query       => l_source
                , p_total_row_count => true
                , p_filters         => l_filters
                , p_columns         => l_columns
            );

            l_context_dml := apex_exec.open_local_dml_context
                ( p_sql_query             => l_source
                , p_columns               => l_columns
                , p_query_type            => apex_exec.c_query_type_sql_query
                , p_lost_update_detection => apex_exec.c_lost_update_none
            );

        --prepare and execute dml -- insert comment
        elsif l_action = 'I' then
        
            l_context_dml := apex_exec.open_local_dml_context
                ( p_sql_query             => l_source
                , p_columns               => l_columns
                , p_query_type            => apex_exec.c_query_type_sql_query
                , p_lost_update_detection => apex_exec.c_lost_update_none
                );
        end if;

        apex_exec.add_dml_row(
            p_context       => l_context_dml
          , p_operation     => l_operation
        ); 

        if l_action in ('U','D') and l_delete_replies != 'DELREPLIES' then

            if apex_exec.next_row( p_context => l_context_query ) then

                apex_exec.set_values(
                    p_context         => l_context_dml,
                    p_source_context  => l_context_query 
                );

            end if;

        end if;

        if l_action in ('I','U') then

            apex_exec.set_value(
              p_context            => l_context_dml
            , p_column_name        => l_id_col
            , p_value              => case when l_action = 'I' then l_id_new else l_id end
            );
            
            apex_exec.set_value(
              p_context            => l_context_dml
            , p_column_name        => l_parent_col
            , p_value              => l_parent_id
            );

            if l_action = 'I' then
                apex_exec.set_value(
                  p_context            => l_context_dml
                , p_column_name        => l_created_date_col
                , p_value              => sysdate
                );
            end if;

            if l_action = 'U' then
                apex_exec.set_value(
                  p_context            => l_context_dml
                , p_column_name        => l_modified_date_col
                , p_value              => sysdate
                );
            end if;

            apex_exec.set_value(
              p_context            => l_context_dml
            , p_column_name        => l_content_col
            , p_value              => l_comment
            );
                       
            apex_exec.set_value(
              p_context            => l_context_dml
            , p_column_name        => l_fullname_col
            , p_value              => l_fullname
            );

            apex_exec.set_value(
              p_context            => l_context_dml
            , p_column_name        => l_profile_picture_url_col
            , p_value              => l_profile_pic
            );

        end if;

        --execute dml
        apex_exec.execute_dml(
          p_context           => l_context_dml
        , p_continue_on_error => false
        );  
            
        apex_exec.close(l_context_dml);
        apex_exec.close(l_context_query);

        apex_json.open_object;

        apex_json.write('success', case when l_action = 'I' then l_id_new else 1 end);

        apex_json.close_object;
    else
        --creating pinging list
        l_pinging_json := get_pinginglist_data(  p_region_pinging => p_region);

        --creating comments JSON
        l_comments_json :=  get_comments_data( p_region_comment => p_region);

        apex_json.initialize_output;

        apex_json.open_object;

        apex_json.write('comments', l_comments_json);
        apex_json.write('pings', l_pinging_json);

        apex_json.close_object; 

    end if;

    return l_return;
exception
    when others then
      apex_json.initialize_output;

      l_apex_error.message             := sqlerrm;
      l_apex_error.ora_sqlcode         := sqlcode;

      apex_json.open_object;

      apex_json.write('status'          , 'error'             );
      apex_json.write('message'         , l_apex_error.ora_sqlcode || ': ' || 
                                          l_apex_error.message);                                         
      apex_json.close_object;

      apex_exec.close(l_context_dml);
      apex_exec.close(l_context_query); 

      return l_return;
end ajax;