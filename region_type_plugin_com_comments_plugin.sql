prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.5'
,p_default_workspace_id=>31247972357692975900
,p_default_application_id=>49061
,p_default_id_offset=>2976922142754886608
,p_default_owner=>'WKSP_RMZRT'
);
end;
/
 
prompt APPLICATION 49061 - Application Express Hungary
--
-- Application Export:
--   Application:     49061
--   Name:            Application Express Hungary
--   Date and Time:   12:10 Monday March 28, 2022
--   Exported By:     BALDOGI.RICHARD@REMEDIOS.HU
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 39826684832934841956
--   Manifest End
--   Version:         21.2.5
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/com_comments_plugin
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(39826684832934841956)
,p_plugin_type=>'REGION TYPE'
,p_name=>'COM.COMMENTS.PLUGIN'
,p_display_name=>'Comments'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#js/jquery-textcomplete.js',
'#PLUGIN_FILES#js/jquery-comments.js',
'#PLUGIN_FILES#js/script.js'))
,p_css_file_urls=>'#PLUGIN_FILES#css/jquery-comments.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  Created by Richard Baldogi',
'--',
'--  This plug-in provides a region where you can write comments.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/baldogiRichard/apex-comments',
'--',
'-- =============================================================================',
'',
'',
'--a boolean function that converts TRUE or FALSE string values into boolean values',
'function get_boolean(p_bool in varchar2)',
'return boolean',
'as',
'begin',
'    return case when upper(p_bool) = ''TRUE''',
'                    then true',
'                when upper(p_bool) = ''FALSE''',
'                    then false',
'                when p_bool = 1',
'                    then true',
'                when p_bool = 0',
'                    then false',
'                when p_bool = ''1''',
'                    then true',
'                when p_bool = ''0''',
'                    then false',
'                end;',
'end get_boolean;',
'',
'--render',
'function render',
'  ( p_region              in apex_plugin.t_region',
'  , p_plugin              in apex_plugin.t_plugin',
'  , p_is_printer_friendly in boolean',
'  )',
'return apex_plugin.t_region_render_result',
'as',
'    l_result                            apex_plugin.t_region_render_result;',
'',
'    --region source',
'    l_source                            p_region.source%type       := p_region.source;',
'    l_context                           apex_exec.t_context;',
'    l_order_by                          apex_exec.t_order_bys;',
'    l_init_js                           varchar2(32767)            := nvl(apex_plugin_util.replace_substitutions(p_region.init_javascript_code), ''undefined'');',
'',
'    --pinging source',
'    l_context_pinging                   apex_exec.t_context;',
'    l_pinging_list                      p_region.attribute_15%type := p_region.attribute_15;',
'',
'    --enable deleting with replies',
'    l_enable_delete                     boolean := (p_region.attribute_19 = ''ENABLE'');',
'    l_enable_delete_w_replies           boolean := (p_region.attribute_20 = ''ENABLE'');',
'',
'    --attributes',
'    l_id_col                            p_region.attribute_01%type := p_region.attribute_01;',
'    l_parent_col                        p_region.attribute_02%type := p_region.attribute_02;',
'    l_created_date_col                  p_region.attribute_03%type := p_region.attribute_03;',
'    l_modified_date_col                 p_region.attribute_04%type := p_region.attribute_04;',
'    l_content_col                       p_region.attribute_05%type := p_region.attribute_05;',
'    l_fullname_col                      p_region.attribute_07%type := p_region.attribute_07;',
'    l_profile_picture_url_col           p_region.attribute_08%type := p_region.attribute_08;',
'    l_created_by_current_user_col       p_region.attribute_10%type := p_region.attribute_10;',
'    l_is_new_col                        p_region.attribute_11%type := p_region.attribute_11;',
'    ',
'    --pinging and editing is enabled',
'    l_pinging                           boolean := (p_region.attribute_14 = ''ENABLE'');',
'    l_editing                           boolean := (p_region.attribute_18 = ''ENABLE'');',
'',
'    --query variables',
'    l_id_col_pos                        pls_integer;',
'    l_parent_col_pos                    pls_integer;',
'    l_created_date_col_pos              pls_integer;',
'    l_modified_date_col_pos             pls_integer;',
'    l_content_col_pos                   pls_integer;',
'    l_fullname_col_pos                  pls_integer;',
'    l_profile_picture_url_col_pos       pls_integer;',
'    l_created_by_current_user_col_pos   pls_integer;',
'    l_is_new_col_pos                    pls_integer;',
'',
'    --pings variables',
'    l_pinging_id                        pls_integer;',
'    l_pinging_name                      pls_integer;',
'    l_pinging_email                     pls_integer;',
'',
'    --comments variables',
'    l_id_col_val                        varchar2(32767);',
'    l_parent_col_val                    varchar2(32767);',
'    l_created_date_col_val              date;',
'    l_modified_date_col_val             date;',
'    l_content_col_val                   clob;',
'    l_fullname_col_val                  varchar2(100);',
'    l_profile_picture_url_col_val       varchar2(1500);',
'    l_created_by_current_user_col_val   varchar2(10);',
'    l_is_new_col_val                    varchar2(10);',
'',
'    --pings variables',
'    l_pinging_id_val                    number;',
'    l_pinging_name_val                  varchar2(100);',
'    l_pinging_email_val                 varchar2(200);',
'',
'    --JSON variables',
'    l_pinging_json                      clob;',
'    l_functionalities_json              clob;',
'    l_comments_json                     clob;',
'',
'    --region and ajax id',
'    l_region_id     p_region.static_id%type    := p_region.static_id;',
'    l_ajax_id       p_region.static_id%type    := apex_plugin.get_ajax_identifier;',
'',
'begin',
'',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_region',
'          ( p_plugin => p_plugin',
'          , p_region => p_region',
'          );',
'    end if;',
'',
'    --create functionalities JSON',
'    apex_json.initialize_clob_output;',
'',
'    apex_json.open_object;',
'',
'        apex_json.write(''regionId''      , l_region_id );',
'        apex_json.write(''ajaxIdentifier'', l_ajax_id   );',
'',
'        --set functionalities',
'        apex_json.write(''enableEditing''                    , case when l_editing                  then TRUE else FALSE end   );',
'        apex_json.write(''enablePinging''                    , case when l_pinging                  then TRUE else FALSE end   );',
'        apex_json.write(''enableDeleting''                   , case when l_enable_delete            then TRUE else FALSE end   );',
'        apex_json.write(''enableDeletingCommentWithReplies'' , case when l_enable_delete_w_replies  then TRUE else FALSE end   );',
'',
'    apex_json.close_object;',
'',
'    l_functionalities_json := apex_json.get_clob_output;',
'',
'    apex_json.free_output;',
'',
'    --creating pinging list JSON',
'    if l_pinging then',
'',
'        l_context_pinging := apex_exec.open_query_context',
'            ( p_location        => apex_exec.c_location_local_db',
'            , p_sql_query       => l_pinging_list',
'            , p_total_row_count => true',
'            );',
'',
'        l_pinging_id    := apex_exec.get_column_position(l_context_pinging, ''ID'');',
'        l_pinging_name  := apex_exec.get_column_position(l_context_pinging, ''NAME'');',
'        l_pinging_email := apex_exec.get_column_position(l_context_pinging, ''EMAIL'');',
'',
'        apex_json.initialize_clob_output;',
'',
'        apex_json.open_array;',
'',
'        while apex_exec.next_row(l_context_pinging) ',
'        loop',
'',
'            l_pinging_id_val    := apex_exec.get_number   (    l_context_pinging, l_pinging_id     );',
'            l_pinging_name_val  := apex_exec.get_varchar2 (    l_context_pinging, l_pinging_name   );',
'            l_pinging_email_val := apex_exec.get_varchar2 (    l_context_pinging, l_pinging_email  );',
'',
'            apex_json.open_object;',
'',
'                apex_json.write(''id''       , l_pinging_id_val    );',
'                apex_json.write(''fullname'' , l_pinging_name_val  );',
'                apex_json.write(''email''    , l_pinging_email_val );',
'',
'            apex_json.close_object;',
'',
'        end loop;',
'',
'        apex_json.close_array;',
'',
'        l_pinging_json := apex_json.get_clob_output;',
'',
'        apex_json.free_output;',
'',
'        apex_exec.close(l_context);',
'',
'    end if;',
'',
'    --creating comments JSON',
'    l_context := apex_exec.open_query_context',
'        ( p_location        => apex_exec.c_location_local_db',
'        , p_sql_query       => l_source',
'        , p_total_row_count => true',
'        );',
'',
'    l_modified_date_col_pos             := apex_exec.get_column_position(l_context, l_modified_date_col);',
'    l_created_by_current_user_col_pos   := apex_exec.get_column_position(l_context, l_created_by_current_user_col);',
'    l_parent_col_pos                    := apex_exec.get_column_position(l_context, l_parent_col);',
'    l_created_date_col_pos              := apex_exec.get_column_position(l_context, l_created_date_col);',
'    l_id_col_pos                        := apex_exec.get_column_position(l_context, l_id_col);',
'    l_content_col_pos                   := apex_exec.get_column_position(l_context, l_content_col);',
'    l_fullname_col_pos                  := apex_exec.get_column_position(l_context, l_fullname_col);',
'    l_profile_picture_url_col_pos       := apex_exec.get_column_position(l_context, l_profile_picture_url_col);',
'    l_is_new_col_pos                    := apex_exec.get_column_position(l_context, l_is_new_col);',
'',
'    apex_json.initialize_clob_output;',
'',
'    apex_json.open_array;',
'',
'    while apex_exec.next_row(l_context) ',
'    loop',
'',
'        apex_json.open_object;',
'',
'            l_modified_date_col_val             := apex_exec.get_varchar2   ( l_context , l_modified_date_col_pos           );',
'            l_created_by_current_user_col_val   := apex_exec.get_varchar2   ( l_context , l_created_by_current_user_col_pos );',
'            l_parent_col_val                    := apex_exec.get_varchar2   ( l_context , l_parent_col_pos                  );',
'            l_id_col_val                        := apex_exec.get_varchar2   ( l_context , l_id_col_pos                      );',
'            l_created_date_col_val              := apex_exec.get_date       ( l_context , l_created_date_col_pos            );',
'            l_content_col_val                   := apex_exec.get_clob       ( l_context , l_content_col_pos                 );',
'            l_fullname_col_val                  := apex_exec.get_varchar2   ( l_context , l_fullname_col_pos                );',
'            l_profile_picture_url_col_val       := apex_exec.get_varchar2   ( l_context , l_profile_picture_url_col_pos     );',
'            l_is_new_col_val                    := apex_exec.get_varchar2   ( l_context , l_is_new_col_pos                  );',
'',
'            apex_json.write(''modified''                , l_modified_date_col_val);',
'            apex_json.write(''created_by_current_user'' , get_boolean(l_created_by_current_user_col_val));',
'            apex_json.write(''parent''                  , l_parent_col_val);',
'            apex_json.write(''id''                      , l_id_col_val);',
'            apex_json.write(''created''                 , l_created_date_col_val);',
'            apex_json.write(''content''                 , l_content_col_val);',
'            apex_json.write(''fullname''                , l_fullname_col_val);',
'            apex_json.write(''profile_picture_url''     , l_profile_picture_url_col_val);',
'            apex_json.write(''is_new''                  , get_boolean(l_is_new_col_val));',
'            apex_json.write_raw(''pings''               , l_pinging_json);',
'',
'        apex_json.close_object;',
'',
'    end loop;',
'',
'    apex_json.close_array;',
'',
'    l_comments_json := apex_json.get_clob_output;',
'',
'    apex_json.free_output;',
'',
'    apex_exec.close(l_context);',
'',
'    --creating JSON for JS initialization',
'    apex_json.initialize_clob_output;    ',
'',
'    apex_json.open_object;',
'',
'        if l_pinging then',
'            apex_json.write_raw(''pingingList''   ,   l_pinging_json          );',
'        end if;',
'',
'        apex_json.write_raw(''comments''          ,   l_comments_json         );',
'        apex_json.write_raw(''functionalities''   ,   l_functionalities_json  );',
'',
'    apex_json.close_object;',
'    ',
'    --Add onload code',
'    apex_javascript.add_onload_code(p_code => ''COMMENTS.initialize('' || apex_json.get_clob_output || '', ''|| l_init_js ||'');'');',
'    ',
'    apex_json.free_output;',
'    ',
'    return l_result;',
'end render;',
'',
'--ajax',
'function ajax',
'    ( p_region in apex_plugin.t_region',
'    , p_plugin in apex_plugin.t_plugin ',
'    )',
'return apex_plugin.t_region_ajax_result',
'as',
'    l_return         apex_plugin.t_region_ajax_result;',
'',
'    -- error handling',
'    l_apex_error     apex_error.t_error;',
'',
'    --dummy value for setting parent id to null when deleting a comment with replies',
'    l_null           varchar2(1)           := null;',
'',
'    --ajax values',
'    l_action         varchar2(1)           := apex_application.g_x01;',
'    l_id             varchar2(32000)       := apex_application.g_x02;',
'    l_parent_id      varchar2(32000)       := apex_application.g_x03;',
'    l_comment        clob                  := apex_application.g_x04;',
'    l_fullname       varchar2(200)         := apex_application.g_x05;',
'    l_delete_replies varchar2(10)          := apex_application.g_x06;',
'',
'    --attributes',
'    l_id_col            p_region.attribute_01%type := p_region.attribute_01;',
'    l_parent_col        p_region.attribute_02%type := p_region.attribute_02;',
'    l_created_date_col  p_region.attribute_03%type := p_region.attribute_03;',
'    l_modified_date_col p_region.attribute_04%type := p_region.attribute_04;',
'    l_content_col       p_region.attribute_05%type := p_region.attribute_05;',
'    l_fullname_col      p_region.attribute_07%type := p_region.attribute_07;',
'',
'    --region source',
'    l_context_dml        apex_exec.t_context;',
'    l_context_query      apex_exec.t_context;',
'    l_columns            apex_exec.t_columns;',
'    l_filters            apex_exec.t_filters;',
'    l_source             p_region.source%type    := p_region.source;',
'',
'    --dml operation',
'    l_enable_delete_w_replies  boolean                    := (p_region.attribute_20 = ''ENABLE'');',
'    l_operation                apex_exec.t_dml_operation  := case when l_action = ''I''',
'                                                                    then apex_exec.c_dml_operation_insert',
'                                                                  when l_action = ''U''',
'                                                                    then apex_exec.c_dml_operation_update',
'                                                                  when l_action = ''D''',
'                                                                    then apex_exec.c_dml_operation_delete',
'                                                              end;',
'',
'    --variables for deleting, updating replies',
'    l_ids_arr          apex_t_varchar2;',
'    l_id_col_pos       pls_integer;',
'    l_id_col_val       varchar2(32767);',
'    l_source_2         p_region.source%type;',
'',
'begin',
'',
'    --debug',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_region',
'          ( p_plugin => p_plugin',
'          , p_region => p_region',
'          );',
'    end if;',
'',
'    --add columns for operation UPDATE, INSERT',
'    if l_delete_replies != ''DELREPLIES'' then',
'',
'        apex_exec.add_column',
'            ( p_columns        => l_columns',
'            , p_column_name    => l_id_col',
'            , p_data_type      => apex_exec.c_data_type_varchar2 ',
'            , p_is_primary_key => true',
'            );',
'',
'        apex_exec.add_column',
'            ( p_columns     => l_columns',
'            , p_column_name => l_parent_col ',
'            , p_data_type   => apex_exec.c_data_type_varchar2 ',
'            );',
'',
'        apex_exec.add_column',
'            ( p_columns     => l_columns',
'            , p_column_name => l_created_date_col ',
'            , p_data_type   => apex_exec.c_data_type_date',
'            );',
'',
'        apex_exec.add_column',
'            ( p_columns     => l_columns',
'            , p_column_name => l_modified_date_col ',
'            , p_data_type   => apex_exec.c_data_type_date',
'            );',
'',
'        apex_exec.add_column',
'            ( p_columns     => l_columns',
'            , p_column_name => l_content_col ',
'            , p_data_type   => apex_exec.c_data_type_clob',
'            );',
'',
'        apex_exec.add_column',
'            ( p_columns     => l_columns',
'            , p_column_name => l_fullname_col ',
'            , p_data_type   => apex_exec.c_data_type_varchar2',
'            );',
'',
'    end if;',
'',
'    --delete, update replies with parent comment if enabled',
'    if l_action in (''U'',''D'') ',
'       and l_enable_delete_w_replies ',
'       and l_delete_replies = ''DELREPLIES'' ',
'    then',
'',
'        if l_action = ''D'' then',
'',
'            apex_exec.add_column(',
'                  p_columns        => l_columns',
'                , p_column_name    => l_id_col',
'                , p_data_type      => apex_exec.c_data_type_varchar2 ',
'                , p_is_primary_key => true',
'            );',
'',
'            --this function returns the IDs of the replies that should be',
'            --updated or deleted',
'',
'            --hierarchical query',
'            l_source_2 := ''select * from ('' || l_source || '') t'' ||',
'                          '' start with t.'' || l_id_col || '' = '''''' || l_id ||',
'                          '''''' connect by prior t.'' || l_id_col || '' = '' || l_parent_col;',
'',
'            --open query context',
'            l_context_query := apex_exec.open_query_context',
'                ( p_location        => apex_exec.c_location_local_db',
'                , p_sql_query       => l_source_2',
'                , p_total_row_count => true',
'                );',
'',
'            l_id_col_pos   := apex_exec.get_column_position(l_context_query, l_id_col);',
'',
'            apex_string.push( l_ids_arr , l_id );',
'',
'            --loop context',
'            while apex_exec.next_row(l_context_query) ',
'            loop',
'                l_id_col_val  := apex_exec.get_varchar2 ( l_context_query , l_id_col_pos );',
'                apex_string.push(l_ids_arr, l_id_col_val);',
'            end loop;',
'',
'            apex_exec.close(l_context_query);',
'',
'            apex_exec.add_filter(',
'                p_filters     => l_filters,',
'                p_filter_type => apex_exec.c_filter_in,',
'                p_column_name => l_id_col,',
'                p_values      => l_ids_arr',
'            );',
'',
'        end if;',
'',
'        if l_action = ''U'' then',
'',
'            apex_exec.add_filter(',
'                p_filters     => l_filters,',
'                p_filter_type => apex_exec.c_filter_eq,',
'                p_column_name => l_parent_col,',
'                p_value       => l_parent_id ',
'            );',
'',
'        end if;',
'',
'        l_context_query := apex_exec.open_query_context',
'            ( p_location        => apex_exec.c_location_local_db',
'            , p_sql_query       => l_source',
'            , p_total_row_count => true',
'            , p_filters         => l_filters',
'            , p_columns         => l_columns',
'            );',
'',
'        l_context_dml := apex_exec.open_local_dml_context',
'            ( p_sql_query             => l_source',
'            , p_columns               => l_columns',
'            , p_query_type            => apex_exec.c_query_type_sql_query',
'            , p_lost_update_detection => apex_exec.c_lost_update_none',
'            );',
'',
'        while apex_exec.next_row(p_context => l_context_query) ',
'        loop',
' ',
'            apex_exec.add_dml_row(',
'                  p_context          => l_context_dml',
'                , p_operation        => l_operation     ',
'                );',
'',
'            apex_exec.set_values(',
'                  p_context         => l_context_dml',
'                , p_source_context  => l_context_query ',
'                );',
'',
'',
'            if l_action = ''U'' then',
'',
'                apex_exec.set_value(',
'                  p_context        => l_context_dml',
'                , p_column_name    => l_parent_col',
'                , p_value          => l_null',
'                );',
'',
'            end if;',
'',
'        end loop;',
'',
'        apex_exec.execute_dml(',
'              p_context           => l_context_dml',
'            , p_continue_on_error => false',
'        );',
'',
'    end if;',
'',
'    --prepare and execute dml -- delete, update current comment',
'    if l_action in (''U'',''D'') and l_delete_replies != ''DELREPLIES'' then',
'',
'        apex_exec.add_filter(',
'            p_filters     => l_filters,',
'            p_filter_type => apex_exec.c_filter_eq,',
'            p_column_name => l_id_col,',
'            p_value       => l_id ',
'        );',
'',
'        l_context_query := apex_exec.open_query_context',
'            ( p_location        => apex_exec.c_location_local_db',
'            , p_sql_query       => l_source',
'            , p_total_row_count => true',
'            , p_filters         => l_filters',
'            , p_columns         => l_columns',
'        );',
'',
'        l_context_dml := apex_exec.open_local_dml_context',
'            ( p_sql_query             => l_source',
'            , p_columns               => l_columns',
'            , p_query_type            => apex_exec.c_query_type_sql_query',
'            , p_lost_update_detection => apex_exec.c_lost_update_none',
'        );',
'',
'    --prepare and execute dml -- insert comment',
'    elsif l_action = ''I'' then',
'',
'        l_context_dml := apex_exec.open_local_dml_context',
'            ( p_sql_query             => l_source',
'            , p_columns               => l_columns',
'            , p_query_type            => apex_exec.c_query_type_sql_query',
'            , p_lost_update_detection => apex_exec.c_lost_update_none',
'            );',
'',
'    end if;',
'',
'    apex_exec.add_dml_row(',
'        p_context       => l_context_dml',
'      , p_operation     => l_operation',
'    );',
'        ',
'    if l_action in (''U'',''D'') and l_delete_replies != ''DELREPLIES'' then',
'',
'        if apex_exec.next_row( p_context => l_context_query ) then',
'',
'            apex_exec.set_values(',
'                p_context         => l_context_dml,',
'                p_source_context  => l_context_query ',
'            );',
'',
'        end if;',
'',
'    end if;',
'',
'    if l_action in (''I'',''U'') then ',
'',
'        apex_exec.set_value(',
'          p_context            => l_context_dml',
'        , p_column_name        => l_id_col',
'        , p_value              => l_id',
'        );',
'',
'        apex_exec.set_value(',
'          p_context            => l_context_dml',
'        , p_column_name        => l_parent_col',
'        , p_value              => l_parent_id',
'        );',
'',
'        if l_action = ''I'' then',
'',
'            apex_exec.set_value(',
'              p_context            => l_context_dml',
'            , p_column_name        => l_created_date_col',
'            , p_value              => sysdate',
'            );',
'',
'        end if;',
'',
'        if l_action = ''U'' then',
'',
'            apex_exec.set_value(',
'              p_context            => l_context_dml',
'            , p_column_name        => l_modified_date_col',
'            , p_value              => sysdate',
'            );',
'',
'        end if;',
'',
'        apex_exec.set_value(',
'          p_context            => l_context_dml',
'        , p_column_name        => l_content_col',
'        , p_value              => l_comment',
'        );           ',
'',
'        apex_exec.set_value(',
'          p_context            => l_context_dml',
'        , p_column_name        => l_fullname_col',
'        , p_value              => l_fullname',
'        );        ',
'',
'    end if;',
'',
'    --execute dml',
'    apex_exec.execute_dml(',
'      p_context           => l_context_dml',
'    , p_continue_on_error => false',
'    );',
'    ',
'    apex_exec.close(l_context_dml);',
'    apex_exec.close(l_context_query);',
'',
'    apex_json.open_object;  ',
'    apex_json.write(''success'', true);  ',
'    apex_json.close_object; ',
'',
'    return l_return;',
'',
'exception',
'    when others then',
'      apex_json.initialize_output;',
'',
'      l_apex_error.message             := sqlerrm;',
'      l_apex_error.ora_sqlcode         := sqlcode;',
'',
'      apex_json.open_object;',
'      ',
'      apex_json.write(''status''          , ''error''             );',
'      apex_json.write(''message''         , l_apex_error.ora_sqlcode || '': '' || ',
'                                          l_apex_error.message);',
'                                          ',
'      apex_json.close_object;',
'',
'      apex_exec.close(l_context_dml);',
'      apex_exec.close(l_context_query);',
'      ',
'      return l_return;',
'',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'SOURCE_LOCATION:AJAX_ITEMS_TO_SUBMIT:ESCAPE_OUTPUT:INIT_JAVASCRIPT_CODE:COLUMNS:HEADING_ALIGNMENT:VALUE_ALIGNMENT:VALUE_CSS:VALUE_ATTRIBUTE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'21.2'
,p_about_url=>'https://github.com/baldogiRichard/apex-comments'
,p_files_version=>1903
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39854869668926406154)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Comment ID:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'ID column for the displayed comment.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39855043135161414281)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Reply ID (Parent):'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'Parent ID column for the displayed comment. If replies are available then the parent ID comment must be available.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39855072535769420693)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Created date:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'DATE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'The date when the comment was created.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39855594451339762640)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Modified date:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'DATE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'The date when the comment was modified or edited.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39855769628996427586)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Comment text:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2:CLOB'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'The actual text/comment which was written by the user.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39856377250803445788)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Username:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'The name of the user who created the comment.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39856700818015788452)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Profile picture URL:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'Profile picture URL of the user.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39857278395714805302)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>90
,p_prompt=>'Created by current user:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2:NUMBER'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The column which indicates whether the comment was made by the logged user or not.',
'',
'Return value: true or false',
'',
'Default value: false'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39858190996737815978)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'New comment:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'VARCHAR2:NUMBER'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A column which can be used to determine whether the comment was made recently or not. By "recent" is determined by the specified query.',
'',
'Return value: true or false',
'',
'Default value: false'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(40282141803567672016)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>160
,p_prompt=>'Pinging'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'DISABLE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Select ''Enable'' if you want to tag users during commenting.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40282148522050672907)
,p_plugin_attribute_id=>wwv_flow_api.id(40282141803567672016)
,p_display_sequence=>10
,p_display_value=>'Enable'
,p_return_value=>'ENABLE'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40282149359223673386)
,p_plugin_attribute_id=>wwv_flow_api.id(40282141803567672016)
,p_display_sequence=>20
,p_display_value=>'Disable'
,p_return_value=>'DISABLE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(40283357562883721254)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>170
,p_prompt=>'Pinging list'
,p_attribute_type=>'SQL'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(40282141803567672016)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ENABLE'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If pinging is enabled, a query must be specified in order to return a list of users whose can be tagged in the comment section.',
'',
'Query format is:',
'',
'select     id',
'         , name',
'         , email',
'from       table'))
);
end;
/
begin
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(40290112733906052207)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_prompt=>'Editing'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'DISABLE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'If enabled the user can edit their own comment(s).'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40290027450408390406)
,p_plugin_attribute_id=>wwv_flow_api.id(40290112733906052207)
,p_display_sequence=>10
,p_display_value=>'Enable'
,p_return_value=>'ENABLE'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40290117343138053246)
,p_plugin_attribute_id=>wwv_flow_api.id(40290112733906052207)
,p_display_sequence=>20
,p_display_value=>'Disable'
,p_return_value=>'DISABLE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(41270604931950703306)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>190
,p_prompt=>'Delete comment'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'DISABLE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'If enabled then users are allowed to delete their comments.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(41270605447003703887)
,p_plugin_attribute_id=>wwv_flow_api.id(41270604931950703306)
,p_display_sequence=>10
,p_display_value=>'Enable'
,p_return_value=>'ENABLE'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(41271005903443042406)
,p_plugin_attribute_id=>wwv_flow_api.id(41270604931950703306)
,p_display_sequence=>20
,p_display_value=>'Disable'
,p_return_value=>'DISABLE'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(41270686638715719035)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>20
,p_display_sequence=>200
,p_prompt=>'Delete comment and replies'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'DISABLE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(41270604931950703306)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ENABLE'
,p_lov_type=>'STATIC'
,p_help_text=>'If enabled the comment and its replies are automatically deleted.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(41271085719367057438)
,p_plugin_attribute_id=>wwv_flow_api.id(41270686638715719035)
,p_display_sequence=>10
,p_display_value=>'Enable'
,p_return_value=>'ENABLE'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(41271086417774057879)
,p_plugin_attribute_id=>wwv_flow_api.id(41270686638715719035)
,p_display_sequence=>20
,p_display_value=>'Disable'
,p_return_value=>'DISABLE'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(39826685478327841959)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(39826685044080841958)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_name=>'SOURCE_LOCATION'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2120202020206A71756572792D636F6D6D656E74732E6A7320312E352E300A202A0A202A20202020202863292032303137204A6F6F6E612054796B6B796CC3A4696E656E2C205669696D6120536F6C7574696F6E73204F790A202A20202020206A71';
wwv_flow_api.g_varchar2_table(2) := '756572792D636F6D6D656E7473206D617920626520667265656C7920646973747269627574656420756E64657220746865204D4954206C6963656E73652E0A202A2020202020466F7220616C6C2064657461696C7320616E6420646F63756D656E746174';
wwv_flow_api.g_varchar2_table(3) := '696F6E3A0A202A2020202020687474703A2F2F7669696D612E6769746875622E696F2F6A71756572792D636F6D6D656E74732F0A202A2F0A0A2866756E6374696F6E2028666163746F727929207B0A2020202069662028747970656F6620646566696E65';
wwv_flow_api.g_varchar2_table(4) := '203D3D3D202766756E6374696F6E2720262620646566696E652E616D6429207B0A20202020202020202F2F20414D442E20526567697374657220617320616E20616E6F6E796D6F7573206D6F64756C652E0A2020202020202020646566696E65285B276A';
wwv_flow_api.g_varchar2_table(5) := '7175657279275D2C20666163746F7279293B0A202020207D20656C73652069662028747970656F66206D6F64756C65203D3D3D20276F626A65637427202626206D6F64756C652E6578706F72747329207B0A20202020202020202F2F204E6F64652F436F';
wwv_flow_api.g_varchar2_table(6) := '6D6D6F6E4A530A20202020202020206D6F64756C652E6578706F727473203D2066756E6374696F6E28726F6F742C206A517565727929207B0A202020202020202020202020696620286A5175657279203D3D3D20756E646566696E656429207B0A202020';
wwv_flow_api.g_varchar2_table(7) := '202020202020202020202020202F2F207265717569726528276A517565727927292072657475726E73206120666163746F727920746861742072657175697265732077696E646F7720746F0A202020202020202020202020202020202F2F206275696C64';
wwv_flow_api.g_varchar2_table(8) := '2061206A517565727920696E7374616E63652C207765206E6F726D616C697A6520686F7720776520757365206D6F64756C65730A202020202020202020202020202020202F2F207468617420726571756972652074686973207061747465726E20627574';
wwv_flow_api.g_varchar2_table(9) := '207468652077696E646F772070726F76696465642069732061206E6F6F700A202020202020202020202020202020202F2F206966206974277320646566696E65642028686F77206A717565727920776F726B73290A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(10) := '2069662028747970656F662077696E646F7720213D3D2027756E646566696E65642729207B0A20202020202020202020202020202020202020206A5175657279203D207265717569726528276A717565727927293B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(11) := '20207D0A20202020202020202020202020202020656C7365207B0A20202020202020202020202020202020202020206A5175657279203D207265717569726528276A7175657279272928726F6F74293B0A202020202020202020202020202020207D0A20';
wwv_flow_api.g_varchar2_table(12) := '20202020202020202020207D0A202020202020202020202020666163746F7279286A5175657279293B0A20202020202020202020202072657475726E206A51756572793B0A20202020202020207D3B0A202020207D20656C7365207B0A20202020202020';
wwv_flow_api.g_varchar2_table(13) := '202F2F2042726F7773657220676C6F62616C730A2020202020202020666163746F7279286A5175657279293B0A202020207D0A7D2866756E6374696F6E282429207B0A0A2020202076617220436F6D6D656E7473203D207B0A0A20202020202020202F2F';
wwv_flow_api.g_varchar2_table(14) := '20496E7374616E6365207661726961626C65730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A202020202020202024656C3A206E756C6C2C0A2020202020202020636F6D6D656E7473427949643A207B7D2C0A20202020';
wwv_flow_api.g_varchar2_table(15) := '2020202064617461466574636865643A2066616C73652C0A202020202020202063757272656E74536F72744B65793A2027272C0A20202020202020206F7074696F6E733A207B7D2C0A20202020202020206576656E74733A207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(16) := '2020202F2F20436C6F73652064726F70646F776E730A20202020202020202020202027636C69636B273A2027636C6F736544726F70646F776E73272C0A0A2020202020202020202020202F2F205061737465206174746163686D656E74730A2020202020';
wwv_flow_api.g_varchar2_table(17) := '2020202020202027706173746527203A2027707265536176655061737465644174746163686D656E7473272C0A0A2020202020202020202020202F2F205361766520636F6D6D656E74206F6E206B6579646F776E0A202020202020202020202020276B65';
wwv_flow_api.g_varchar2_table(18) := '79646F776E205B636F6E74656E746564697461626C655D27203A2027736176654F6E4B6579646F776E272C0A0A2020202020202020202020202F2F204C697374656E696E67206368616E67657320696E20636F6E74656E746564697461626C6520666965';
wwv_flow_api.g_varchar2_table(19) := '6C6473202864756520746F20696E707574206576656E74206E6F7420776F726B696E672077697468204945290A20202020202020202020202027666F637573205B636F6E74656E746564697461626C655D27203A2027736176654564697461626C65436F';
wwv_flow_api.g_varchar2_table(20) := '6E74656E74272C0A202020202020202020202020276B65797570205B636F6E74656E746564697461626C655D27203A2027636865636B4564697461626C65436F6E74656E74466F724368616E6765272C0A20202020202020202020202027706173746520';
wwv_flow_api.g_varchar2_table(21) := '5B636F6E74656E746564697461626C655D27203A2027636865636B4564697461626C65436F6E74656E74466F724368616E6765272C0A20202020202020202020202027696E707574205B636F6E74656E746564697461626C655D27203A2027636865636B';
wwv_flow_api.g_varchar2_table(22) := '4564697461626C65436F6E74656E74466F724368616E6765272C0A20202020202020202020202027626C7572205B636F6E74656E746564697461626C655D27203A2027636865636B4564697461626C65436F6E74656E74466F724368616E6765272C0A0A';
wwv_flow_api.g_varchar2_table(23) := '2020202020202020202020202F2F204E617669676174696F6E0A20202020202020202020202027636C69636B202E6E617669676174696F6E206C695B646174612D736F72742D6B65795D27203A20276E617669676174696F6E456C656D656E74436C6963';
wwv_flow_api.g_varchar2_table(24) := '6B6564272C0A20202020202020202020202027636C69636B202E6E617669676174696F6E206C692E7469746C6527203A2027746F67676C654E617669676174696F6E44726F70646F776E272C0A0A2020202020202020202020202F2F204D61696E20636F';
wwv_flow_api.g_varchar2_table(25) := '6D656E74696E67206669656C640A20202020202020202020202027636C69636B202E636F6D6D656E74696E672D6669656C642E6D61696E202E7465787461726561273A202773686F774D61696E436F6D6D656E74696E674669656C64272C0A2020202020';
wwv_flow_api.g_varchar2_table(26) := '2020202020202027636C69636B202E636F6D6D656E74696E672D6669656C642E6D61696E202E636C6F736527203A2027686964654D61696E436F6D6D656E74696E674669656C64272C0A0A2020202020202020202020202F2F20416C6C20636F6D6D656E';
wwv_flow_api.g_varchar2_table(27) := '74696E67206669656C64730A20202020202020202020202027636C69636B202E636F6D6D656E74696E672D6669656C64202E746578746172656127203A2027696E6372656173655465787461726561486569676874272C0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(28) := '276368616E6765202E636F6D6D656E74696E672D6669656C64202E746578746172656127203A2027696E6372656173655465787461726561486569676874207465787461726561436F6E74656E744368616E676564272C0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(29) := '27636C69636B202E636F6D6D656E74696E672D6669656C643A6E6F74282E6D61696E29202E636C6F736527203A202772656D6F7665436F6D6D656E74696E674669656C64272C0A0A2020202020202020202020202F2F2045646974206D6F646520616374';
wwv_flow_api.g_varchar2_table(30) := '696F6E730A20202020202020202020202027636C69636B202E636F6D6D656E74696E672D6669656C64202E73656E642E656E61626C656427203A2027706F7374436F6D6D656E74272C0A20202020202020202020202027636C69636B202E636F6D6D656E';
wwv_flow_api.g_varchar2_table(31) := '74696E672D6669656C64202E7570646174652E656E61626C656427203A2027707574436F6D6D656E74272C0A20202020202020202020202027636C69636B202E636F6D6D656E74696E672D6669656C64202E64656C6574652E656E61626C656427203A20';
wwv_flow_api.g_varchar2_table(32) := '2764656C657465436F6D6D656E74272C0A20202020202020202020202027636C69636B202E636F6D6D656E74696E672D6669656C64202E6174746163686D656E7473202E6174746163686D656E74202E64656C65746527203A202770726544656C657465';
wwv_flow_api.g_varchar2_table(33) := '4174746163686D656E74272C0A202020202020202020202020276368616E6765202E636F6D6D656E74696E672D6669656C64202E75706C6F61642E656E61626C656420696E7075745B747970653D2266696C65225D27203A202766696C65496E70757443';
wwv_flow_api.g_varchar2_table(34) := '68616E676564272C0A0A2020202020202020202020202F2F204F7468657220616374696F6E730A20202020202020202020202027636C69636B206C692E636F6D6D656E7420627574746F6E2E7570766F746527203A20277570766F7465436F6D6D656E74';
wwv_flow_api.g_varchar2_table(35) := '272C0A20202020202020202020202027636C69636B206C692E636F6D6D656E7420627574746F6E2E64656C6574652E656E61626C656427203A202764656C657465436F6D6D656E74272C0A20202020202020202020202027636C69636B206C692E636F6D';
wwv_flow_api.g_varchar2_table(36) := '6D656E74202E6861736874616727203A202768617368746167436C69636B6564272C0A20202020202020202020202027636C69636B206C692E636F6D6D656E74202E70696E6727203A202770696E67436C69636B6564272C0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(37) := '20202F2F204F746865720A20202020202020202020202027636C69636B206C692E636F6D6D656E7420756C2E6368696C642D636F6D6D656E7473202E746F67676C652D616C6C273A2027746F67676C655265706C696573272C0A20202020202020202020';
wwv_flow_api.g_varchar2_table(38) := '202027636C69636B206C692E636F6D6D656E7420627574746F6E2E7265706C79273A20277265706C79427574746F6E436C69636B6564272C0A20202020202020202020202027636C69636B206C692E636F6D6D656E7420627574746F6E2E65646974273A';
wwv_flow_api.g_varchar2_table(39) := '202765646974427574746F6E436C69636B6564272C0A0A2020202020202020202020202F2F204472616720262064726F7070696E67206174746163686D656E74730A2020202020202020202020202764726167656E74657227203A202773686F7744726F';
wwv_flow_api.g_varchar2_table(40) := '707061626C654F7665726C6179272C0A0A2020202020202020202020202764726167656E746572202E64726F707061626C652D6F7665726C617927203A202768616E646C6544726167456E746572272C0A20202020202020202020202027647261676C65';
wwv_flow_api.g_varchar2_table(41) := '617665202E64726F707061626C652D6F7665726C617927203A202768616E646C65447261674C65617665466F724F7665726C6179272C0A2020202020202020202020202764726167656E746572202E64726F707061626C652D6F7665726C6179202E6472';
wwv_flow_api.g_varchar2_table(42) := '6F707061626C6527203A202768616E646C6544726167456E746572272C0A20202020202020202020202027647261676C65617665202E64726F707061626C652D6F7665726C6179202E64726F707061626C6527203A202768616E646C65447261674C6561';
wwv_flow_api.g_varchar2_table(43) := '7665466F7244726F707061626C65272C0A0A20202020202020202020202027647261676F766572202E64726F707061626C652D6F7665726C617927203A202768616E646C65447261674F766572466F724F7665726C6179272C0A20202020202020202020';
wwv_flow_api.g_varchar2_table(44) := '20202764726F70202E64726F707061626C652D6F7665726C617927203A202768616E646C6544726F70272C0A0A2020202020202020202020202F2F2050726576656E742070726F7061676174696E672074686520636C69636B206576656E7420696E746F';
wwv_flow_api.g_varchar2_table(45) := '20627574746F6E7320756E64657220746865206175746F636F6D706C6574652064726F70646F776E0A20202020202020202020202027636C69636B202E64726F70646F776E2E6175746F636F6D706C657465273A202773746F7050726F7061676174696F';
wwv_flow_api.g_varchar2_table(46) := '6E272C0A202020202020202020202020276D6F757365646F776E202E64726F70646F776E2E6175746F636F6D706C657465273A202773746F7050726F7061676174696F6E272C0A20202020202020202020202027746F7563687374617274202E64726F70';
wwv_flow_api.g_varchar2_table(47) := '646F776E2E6175746F636F6D706C657465273A202773746F7050726F7061676174696F6E272C0A20202020202020207D2C0A0A0A20202020202020202F2F2044656661756C74206F7074696F6E730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D';
wwv_flow_api.g_varchar2_table(48) := '3D3D3D3D3D0A0A202020202020202067657444656661756C744F7074696F6E733A2066756E6374696F6E2829207B0A20202020202020202020202072657475726E207B0A0A202020202020202020202020202020202F2F20557365720A20202020202020';
wwv_flow_api.g_varchar2_table(49) := '20202020202020202070726F66696C655069637475726555524C3A2027272C0A2020202020202020202020202020202063757272656E7455736572497341646D696E3A2066616C73652C0A2020202020202020202020202020202063757272656E745573';
wwv_flow_api.g_varchar2_table(50) := '657249643A206E756C6C2C0A0A202020202020202020202020202020202F2F20466F6E7420617765736F6D652069636F6E206F76657272696465730A202020202020202020202020202020207370696E6E657249636F6E55524C3A2027272C0A20202020';
wwv_flow_api.g_varchar2_table(51) := '2020202020202020202020207570766F746549636F6E55524C3A2027272C0A202020202020202020202020202020207265706C7949636F6E55524C3A2027272C0A2020202020202020202020202020202075706C6F616449636F6E55524C3A2027272C0A';
wwv_flow_api.g_varchar2_table(52) := '202020202020202020202020202020206174746163686D656E7449636F6E55524C3A2027272C0A202020202020202020202020202020206E6F436F6D6D656E747349636F6E55524C3A2027272C0A20202020202020202020202020202020636C6F736549';
wwv_flow_api.g_varchar2_table(53) := '636F6E55524C3A2027272C0A0A202020202020202020202020202020202F2F20537472696E677320746F20626520666F726D61747465642028666F72206578616D706C65206C6F63616C697A6174696F6E290A2020202020202020202020202020202074';
wwv_flow_api.g_varchar2_table(54) := '65787461726561506C616365686F6C646572546578743A2027416464206120636F6D6D656E74272C0A202020202020202020202020202020206E6577657374546578743A20274E6577657374272C0A202020202020202020202020202020206F6C646573';
wwv_flow_api.g_varchar2_table(55) := '74546578743A20274F6C64657374272C0A20202020202020202020202020202020706F70756C6172546578743A2027506F70756C6172272C0A202020202020202020202020202020206174746163686D656E7473546578743A20274174746163686D656E';
wwv_flow_api.g_varchar2_table(56) := '7473272C0A2020202020202020202020202020202073656E64546578743A202753656E64272C0A202020202020202020202020202020207265706C79546578743A20275265706C79272C0A2020202020202020202020202020202065646974546578743A';
wwv_flow_api.g_varchar2_table(57) := '202745646974272C0A20202020202020202020202020202020656469746564546578743A2027456469746564272C0A20202020202020202020202020202020796F75546578743A2027596F75272C0A202020202020202020202020202020207361766554';
wwv_flow_api.g_varchar2_table(58) := '6578743A202753617665272C0A2020202020202020202020202020202064656C657465546578743A202744656C657465272C0A202020202020202020202020202020206E6577546578743A20274E6577272C0A2020202020202020202020202020202076';
wwv_flow_api.g_varchar2_table(59) := '696577416C6C5265706C696573546578743A20275669657720616C6C205F5F7265706C79436F756E745F5F207265706C696573272C0A20202020202020202020202020202020686964655265706C696573546578743A202748696465207265706C696573';
wwv_flow_api.g_varchar2_table(60) := '272C0A202020202020202020202020202020206E6F436F6D6D656E7473546578743A20274E6F20636F6D6D656E7473272C0A202020202020202020202020202020206E6F4174746163686D656E7473546578743A20274E6F206174746163686D656E7473';
wwv_flow_api.g_varchar2_table(61) := '272C0A202020202020202020202020202020206174746163686D656E7444726F70546578743A202744726F702066696C65732068657265272C0A2020202020202020202020202020202074657874466F726D61747465723A2066756E6374696F6E287465';
wwv_flow_api.g_varchar2_table(62) := '787429207B72657475726E20746578747D2C0A0A202020202020202020202020202020202F2F2046756E6374696F6E616C69746965730A20202020202020202020202020202020656E61626C655265706C79696E673A20747275652C0A20202020202020';
wwv_flow_api.g_varchar2_table(63) := '202020202020202020656E61626C6545646974696E673A20747275652C0A20202020202020202020202020202020656E61626C655570766F74696E673A20747275652C0A20202020202020202020202020202020656E61626C6544656C6574696E673A20';
wwv_flow_api.g_varchar2_table(64) := '747275652C0A20202020202020202020202020202020656E61626C654174746163686D656E74733A2066616C73652C0A20202020202020202020202020202020656E61626C6548617368746167733A2066616C73652C0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(65) := '202020656E61626C6550696E67696E673A2066616C73652C0A20202020202020202020202020202020656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965733A2066616C73652C0A20202020202020202020202020202020656E';
wwv_flow_api.g_varchar2_table(66) := '61626C654E617669676174696F6E3A20747275652C0A20202020202020202020202020202020706F7374436F6D6D656E744F6E456E7465723A2066616C73652C0A20202020202020202020202020202020666F726365526573706F6E736976653A206661';
wwv_flow_api.g_varchar2_table(67) := '6C73652C0A20202020202020202020202020202020726561644F6E6C793A2066616C73652C0A2020202020202020202020202020202064656661756C744E617669676174696F6E536F72744B65793A20276E6577657374272C0A0A202020202020202020';
wwv_flow_api.g_varchar2_table(68) := '202020202020202F2F20436F6C6F72730A20202020202020202020202020202020686967686C69676874436F6C6F723A202723323739336536272C0A2020202020202020202020202020202064656C657465427574746F6E436F6C6F723A202723433933';
wwv_flow_api.g_varchar2_table(69) := '303243272C0A0A202020202020202020202020202020207363726F6C6C436F6E7461696E65723A20746869732E24656C2C0A20202020202020202020202020202020726F756E6450726F66696C6550696374757265733A2066616C73652C0A2020202020';
wwv_flow_api.g_varchar2_table(70) := '20202020202020202020207465787461726561526F77733A20322C0A202020202020202020202020202020207465787461726561526F77734F6E466F6375733A20322C0A2020202020202020202020202020202074657874617265614D6178526F77733A';
wwv_flow_api.g_varchar2_table(71) := '20352C0A202020202020202020202020202020206D61785265706C69657356697369626C653A20322C0A0A202020202020202020202020202020206669656C644D617070696E67733A207B0A202020202020202020202020202020202020202069643A20';
wwv_flow_api.g_varchar2_table(72) := '276964272C0A2020202020202020202020202020202020202020706172656E743A2027706172656E74272C0A2020202020202020202020202020202020202020637265617465643A202763726561746564272C0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(73) := '202020206D6F6469666965643A20276D6F646966696564272C0A2020202020202020202020202020202020202020636F6E74656E743A2027636F6E74656E74272C0A20202020202020202020202020202020202020206174746163686D656E74733A2027';
wwv_flow_api.g_varchar2_table(74) := '6174746163686D656E7473272C0A202020202020202020202020202020202020202070696E67733A202770696E6773272C0A202020202020202020202020202020202020202063726561746F723A202763726561746F72272C0A20202020202020202020';
wwv_flow_api.g_varchar2_table(75) := '2020202020202020202066756C6C6E616D653A202766756C6C6E616D65272C0A202020202020202020202020202020202020202070726F66696C655069637475726555524C3A202770726F66696C655F706963747572655F75726C272C0A202020202020';
wwv_flow_api.g_varchar2_table(76) := '202020202020202020202020202069734E65773A202769735F6E6577272C0A202020202020202020202020202020202020202063726561746564427941646D696E3A2027637265617465645F62795F61646D696E272C0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(77) := '2020202020202063726561746564427943757272656E74557365723A2027637265617465645F62795F63757272656E745F75736572272C0A20202020202020202020202020202020202020207570766F7465436F756E743A20277570766F74655F636F75';
wwv_flow_api.g_varchar2_table(78) := '6E74272C0A2020202020202020202020202020202020202020757365724861735570766F7465643A2027757365725F6861735F7570766F746564270A202020202020202020202020202020207D2C0A0A2020202020202020202020202020202073656172';
wwv_flow_api.g_varchar2_table(79) := '636855736572733A2066756E6374696F6E287465726D2C20737563636573732C206572726F7229207B73756363657373285B5D297D2C0A20202020202020202020202020202020676574436F6D6D656E74733A2066756E6374696F6E2873756363657373';
wwv_flow_api.g_varchar2_table(80) := '2C206572726F7229207B73756363657373285B5D297D2C0A20202020202020202020202020202020706F7374436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B7375636365737328';
wwv_flow_api.g_varchar2_table(81) := '636F6D6D656E744A534F4E297D2C0A20202020202020202020202020202020707574436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B7375636365737328636F6D6D656E744A534F';
wwv_flow_api.g_varchar2_table(82) := '4E297D2C0A2020202020202020202020202020202064656C657465436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B7375636365737328297D2C0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(83) := '2020207570766F7465436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B7375636365737328636F6D6D656E744A534F4E297D2C0A2020202020202020202020202020202076616C69';
wwv_flow_api.g_varchar2_table(84) := '646174654174746163686D656E74733A2066756E6374696F6E286174746163686D656E74732C2063616C6C6261636B29207B72657475726E2063616C6C6261636B286174746163686D656E7473297D2C0A20202020202020202020202020202020686173';
wwv_flow_api.g_varchar2_table(85) := '68746167436C69636B65643A2066756E6374696F6E286861736874616729207B7D2C0A2020202020202020202020202020202070696E67436C69636B65643A2066756E6374696F6E2875736572496429207B7D2C0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(86) := '20726566726573683A2066756E6374696F6E2829207B7D2C0A2020202020202020202020202020202074696D65466F726D61747465723A2066756E6374696F6E2874696D6529207B72657475726E206E657720446174652874696D65292E746F4C6F6361';
wwv_flow_api.g_varchar2_table(87) := '6C6544617465537472696E6728297D0A2020202020202020202020207D0A20202020202020207D2C0A0A0A20202020202020202F2F20496E697469616C697A6174696F6E0A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A20202020';
wwv_flow_api.g_varchar2_table(88) := '20202020696E69743A2066756E6374696F6E286F7074696F6E732C20656C29207B0A202020202020202020202020746869732E24656C203D202428656C293B0A202020202020202020202020746869732E24656C2E616464436C61737328276A71756572';
wwv_flow_api.g_varchar2_table(89) := '792D636F6D6D656E747327293B0A202020202020202020202020746869732E756E64656C65676174654576656E747328293B0A202020202020202020202020746869732E64656C65676174654576656E747328293B0A0A2020202020202020202020202F';
wwv_flow_api.g_varchar2_table(90) := '2F20446574656374206D6F62696C6520646576696365730A2020202020202020202020202866756E6374696F6E2861297B286A51756572792E62726F777365723D6A51756572792E62726F777365727C7C7B7D292E6D6F62696C653D2F28616E64726F69';
wwv_flow_api.g_varchar2_table(91) := '647C62625C642B7C6D6565676F292E2B6D6F62696C657C6176616E74676F7C626164615C2F7C626C61636B62657272797C626C617A65727C636F6D70616C7C656C61696E657C66656E6E65637C686970746F707C69656D6F62696C657C697028686F6E65';
wwv_flow_api.g_varchar2_table(92) := '7C6F64297C697269737C6B696E646C657C6C6765207C6D61656D6F7C6D6964707C6D6D707C6D6F62696C652E2B66697265666F787C6E657466726F6E747C6F70657261206D286F627C696E29697C70616C6D28206F73293F7C70686F6E657C7028697869';
wwv_flow_api.g_varchar2_table(93) := '7C7265295C2F7C706C75636B65727C706F636B65747C7073707C73657269657328347C3629307C73796D6269616E7C7472656F7C75705C2E2862726F777365727C6C696E6B297C766F6461666F6E657C7761707C77696E646F77732063657C7864617C78';
wwv_flow_api.g_varchar2_table(94) := '69696E6F2F692E746573742861297C7C2F313230377C363331307C363539307C3367736F7C347468707C35305B312D365D697C373730737C383032737C612077617C616261637C61632865727C6F6F7C735C2D297C6169286B6F7C726E297C616C286176';
wwv_flow_api.g_varchar2_table(95) := '7C63617C636F297C616D6F697C616E2865787C6E797C7977297C617074757C61722863687C676F297C61732874657C7573297C617474777C61752864697C5C2D6D7C72207C7320297C6176616E7C626528636B7C6C6C7C6E71297C6269286C627C726429';
wwv_flow_api.g_varchar2_table(96) := '7C626C2861637C617A297C627228657C7629777C62756D627C62775C2D286E7C75297C6335355C2F7C636170697C636377617C63646D5C2D7C63656C6C7C6368746D7C636C64637C636D645C2D7C636F286D707C6E64297C637261777C64612869747C6C';
wwv_flow_api.g_varchar2_table(97) := '6C7C6E67297C646274657C64635C2D737C646576697C646963617C646D6F627C646F28637C70296F7C64732831327C5C2D64297C656C2834397C6169297C656D286C327C756C297C65722869637C6B30297C65736C387C657A285B342D375D307C6F737C';
wwv_flow_api.g_varchar2_table(98) := '77617C7A65297C666574637C666C79285C2D7C5F297C673120757C673536307C67656E657C67665C2D357C675C2D6D6F7C676F285C2E777C6F64297C67722861647C756E297C686169657C686369747C68645C2D286D7C707C74297C6865695C2D7C6869';
wwv_flow_api.g_varchar2_table(99) := '2870747C7461297C68702820697C6970297C68735C2D637C68742863285C2D7C207C5F7C617C677C707C737C74297C7470297C68752861777C7463297C695C2D2832307C676F7C6D61297C693233307C69616328207C5C2D7C5C2F297C6962726F7C6964';
wwv_flow_api.g_varchar2_table(100) := '65617C696730317C696B6F6D7C696D316B7C696E6E6F7C697061717C697269737C6A6128747C7629617C6A62726F7C6A656D757C6A6967737C6B6464697C6B656A697C6B677428207C5C2F297C6B6C6F6E7C6B7074207C6B77635C2D7C6B796F28637C6B';
wwv_flow_api.g_varchar2_table(101) := '297C6C65286E6F7C7869297C6C672820677C5C2F286B7C6C7C75297C35307C35347C5C2D5B612D775D297C6C6962777C6C796E787C6D315C2D777C6D3367617C6D35305C2F7C6D612874657C75697C786F297C6D632830317C32317C6361297C6D5C2D63';
wwv_flow_api.g_varchar2_table(102) := '727C6D652872637C7269297C6D69286F387C6F617C7473297C6D6D65667C6D6F2830317C30327C62697C64657C646F7C74285C2D7C207C6F7C76297C7A7A297C6D742835307C70317C7620297C6D7762707C6D7977617C6E31305B302D325D7C6E32305B';
wwv_flow_api.g_varchar2_table(103) := '322D335D7C6E333028307C32297C6E353028307C327C35297C6E37283028307C31297C3130297C6E652828637C6D295C2D7C6F6E7C74667C77667C77677C7774297C6E6F6B28367C69297C6E7A70687C6F32696D7C6F702874697C7776297C6F72616E7C';
wwv_flow_api.g_varchar2_table(104) := '6F7767317C703830307C70616E28617C647C74297C706478677C70672831337C5C2D285B312D385D7C6329297C7068696C7C706972657C706C2861797C7563297C706E5C2D327C706F28636B7C72747C7365297C70726F787C7073696F7C70745C2D677C';
wwv_flow_api.g_varchar2_table(105) := '71615C2D617C71632830377C31327C32317C33327C36307C5C2D5B322D375D7C695C2D297C7174656B7C723338307C723630307C72616B737C72696D397C726F2876657C7A6F297C7335355C2F7C73612867657C6D617C6D6D7C6D737C6E797C7661297C';
wwv_flow_api.g_varchar2_table(106) := '73632830317C685C2D7C6F6F7C705C2D297C73646B5C2F7C73652863285C2D7C307C31297C34377C6D637C6E647C7269297C7367685C2D7C736861727C736965285C2D7C6D297C736B5C2D307C736C2834357C6964297C736D28616C7C61727C62337C69';
wwv_flow_api.g_varchar2_table(107) := '747C7435297C736F2866747C6E79297C73702830317C685C2D7C765C2D7C7620297C73792830317C6D62297C74322831387C3530297C74362830307C31307C3138297C74612867747C6C6B297C74636C5C2D7C7464675C2D7C74656C28697C6D297C7469';
wwv_flow_api.g_varchar2_table(108) := '6D5C2D7C745C2D6D6F7C746F28706C7C7368297C74732837307C6D5C2D7C6D337C6D35297C74785C2D397C7570285C2E627C67317C7369297C757473747C763430307C763735307C766572697C76692872677C7465297C766B2834307C355B302D335D7C';
wwv_flow_api.g_varchar2_table(109) := '5C2D76297C766D34307C766F64617C76756C637C76782835327C35337C36307C36317C37307C38307C38317C38337C38357C3938297C773363285C2D7C20297C776562637C776869747C77692867207C6E637C6E77297C776D6C627C776F6E757C783730';
wwv_flow_api.g_varchar2_table(110) := '307C7961735C2D7C796F75727C7A65746F7C7A74655C2D2F692E7465737428612E73756273747228302C3429297D29286E6176696761746F722E757365724167656E747C7C6E6176696761746F722E76656E646F727C7C77696E646F772E6F7065726129';
wwv_flow_api.g_varchar2_table(111) := '3B0A202020202020202020202020696628242E62726F777365722E6D6F62696C652920746869732E24656C2E616464436C61737328276D6F62696C6527293B0A0A2020202020202020202020202F2F20496E6974206F7074696F6E730A20202020202020';
wwv_flow_api.g_varchar2_table(112) := '2020202020746869732E6F7074696F6E73203D20242E657874656E6428747275652C207B7D2C20746869732E67657444656661756C744F7074696F6E7328292C206F7074696F6E73293B3B0A0A2020202020202020202020202F2F20526561642D6F6E6C';
wwv_flow_api.g_varchar2_table(113) := '79206D6F64650A202020202020202020202020696628746869732E6F7074696F6E732E726561644F6E6C792920746869732E24656C2E616464436C6173732827726561642D6F6E6C7927293B0A0A2020202020202020202020202F2F2053657420696E69';
wwv_flow_api.g_varchar2_table(114) := '7469616C20736F7274206B65790A202020202020202020202020746869732E63757272656E74536F72744B6579203D20746869732E6F7074696F6E732E64656661756C744E617669676174696F6E536F72744B65793B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(115) := '2F2F2043726561746520435353206465636C61726174696F6E7320666F7220686967686C6967687420636F6C6F720A202020202020202020202020746869732E6372656174654373734465636C61726174696F6E7328293B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(116) := '20202F2F204665746368696E67206461746120616E642072656E646572696E670A202020202020202020202020746869732E666574636844617461416E6452656E64657228293B0A20202020202020207D2C0A0A202020202020202064656C6567617465';
wwv_flow_api.g_varchar2_table(117) := '4576656E74733A2066756E6374696F6E2829207B0A202020202020202020202020746869732E62696E644576656E74732866616C7365293B0A20202020202020207D2C0A0A2020202020202020756E64656C65676174654576656E74733A2066756E6374';
wwv_flow_api.g_varchar2_table(118) := '696F6E2829207B0A202020202020202020202020746869732E62696E644576656E74732874727565293B0A20202020202020207D2C0A0A202020202020202062696E644576656E74733A2066756E6374696F6E28756E62696E6429207B0A202020202020';
wwv_flow_api.g_varchar2_table(119) := '2020202020207661722062696E6446756E6374696F6E203D20756E62696E64203F20276F666627203A20276F6E273B0A202020202020202020202020666F722028766172206B657920696E20746869732E6576656E747329207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(120) := '20202020202020766172206576656E744E616D65203D206B65792E73706C697428272027295B305D3B0A202020202020202020202020202020207661722073656C6563746F72203D206B65792E73706C697428272027292E736C6963652831292E6A6F69';
wwv_flow_api.g_varchar2_table(121) := '6E28272027293B0A20202020202020202020202020202020766172206D6574686F644E616D6573203D20746869732E6576656E74735B6B65795D2E73706C697428272027293B0A0A20202020202020202020202020202020666F722876617220696E6465';
wwv_flow_api.g_varchar2_table(122) := '7820696E206D6574686F644E616D657329207B0A20202020202020202020202020202020202020206966286D6574686F644E616D65732E6861734F776E50726F706572747928696E6465782929207B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(123) := '20202020766172206D6574686F64203D20746869735B6D6574686F644E616D65735B696E6465785D5D3B0A0A2020202020202020202020202020202020202020202020202F2F204B6565702074686520636F6E746578740A202020202020202020202020';
wwv_flow_api.g_varchar2_table(124) := '2020202020202020202020206D6574686F64203D20242E70726F7879286D6574686F642C2074686973293B0A0A2020202020202020202020202020202020202020202020206966202873656C6563746F72203D3D20272729207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(125) := '20202020202020202020202020202020202020746869732E24656C5B62696E6446756E6374696F6E5D286576656E744E616D652C206D6574686F64293B0A2020202020202020202020202020202020202020202020207D20656C7365207B0A2020202020';
wwv_flow_api.g_varchar2_table(126) := '2020202020202020202020202020202020202020202020746869732E24656C5B62696E6446756E6374696F6E5D286576656E744E616D652C2073656C6563746F722C206D6574686F64293B0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(127) := '7D0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A0A20202020202020202F2F2042617369632066756E6374696F6E616C69746965';
wwv_flow_api.g_varchar2_table(128) := '730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A2020202020202020666574636844617461416E6452656E6465723A2066756E6374696F6E202829207B0A2020202020202020202020207661722073656C66203D';
wwv_flow_api.g_varchar2_table(129) := '20746869733B0A0A202020202020202020202020746869732E636F6D6D656E747342794964203D207B7D3B0A0A202020202020202020202020746869732E24656C2E656D70747928293B0A202020202020202020202020746869732E6372656174654854';
wwv_flow_api.g_varchar2_table(130) := '4D4C28293B0A0A2020202020202020202020202F2F20436F6D6D656E74730A2020202020202020202020202F2F203D3D3D3D3D3D3D3D0A0A202020202020202020202020746869732E6F7074696F6E732E676574436F6D6D656E74732866756E6374696F';
wwv_flow_api.g_varchar2_table(131) := '6E28636F6D6D656E7473417272617929207B0A0A202020202020202020202020202020202F2F20436F6E7665727420636F6D6D656E747320746F20637573746F6D2064617461206D6F64656C0A2020202020202020202020202020202076617220636F6D';
wwv_flow_api.g_varchar2_table(132) := '6D656E744D6F64656C73203D20636F6D6D656E747341727261792E6D61702866756E6374696F6E28636F6D6D656E74734A534F4E297B0A202020202020202020202020202020202020202072657475726E2073656C662E637265617465436F6D6D656E74';
wwv_flow_api.g_varchar2_table(133) := '4D6F64656C28636F6D6D656E74734A534F4E290A202020202020202020202020202020207D293B0A0A202020202020202020202020202020202F2F20536F727420636F6D6D656E7473206279206461746520286F6C6465737420666972737420736F2074';
wwv_flow_api.g_varchar2_table(134) := '68617420746865792063616E20626520617070656E64656420746F207468652064617461206D6F64656C0A202020202020202020202020202020202F2F20776974686F757420636172696E6720646570656E64656E63696573290A202020202020202020';
wwv_flow_api.g_varchar2_table(135) := '2020202020202073656C662E736F7274436F6D6D656E747328636F6D6D656E744D6F64656C732C20276F6C6465737427293B0A0A202020202020202020202020202020202428636F6D6D656E744D6F64656C73292E656163682866756E6374696F6E2869';
wwv_flow_api.g_varchar2_table(136) := '6E6465782C20636F6D6D656E744D6F64656C29207B0A202020202020202020202020202020202020202073656C662E616464436F6D6D656E74546F446174614D6F64656C28636F6D6D656E744D6F64656C293B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(137) := '7D293B0A0A202020202020202020202020202020202F2F204D61726B206461746120617320666574636865640A2020202020202020202020202020202073656C662E6461746146657463686564203D20747275653B0A0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(138) := '2020202F2F2052656E6465720A2020202020202020202020202020202073656C662E72656E64657228293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A202020202020202066657463684E6578743A2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(139) := '29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A2020202020202020202020202F2F204C6F6164696E6720696E64696361746F720A202020202020202020202020766172207370696E6E6572203D20746869732E6372';
wwv_flow_api.g_varchar2_table(140) := '656174655370696E6E657228293B0A202020202020202020202020746869732E24656C2E66696E642827756C23636F6D6D656E742D6C69737427292E617070656E64287370696E6E6572293B0A0A20202020202020202020202076617220737563636573';
wwv_flow_api.g_varchar2_table(141) := '73203D2066756E6374696F6E2028636F6D6D656E744D6F64656C7329207B0A202020202020202020202020202020202428636F6D6D656E744D6F64656C73292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B';
wwv_flow_api.g_varchar2_table(142) := '0A202020202020202020202020202020202020202073656C662E637265617465436F6D6D656E7428636F6D6D656E744D6F64656C293B0A202020202020202020202020202020207D293B0A202020202020202020202020202020207370696E6E65722E72';
wwv_flow_api.g_varchar2_table(143) := '656D6F766528293B0A2020202020202020202020207D0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A202020202020202020202020202020207370696E6E65722E72656D6F766528293B0A2020202020';
wwv_flow_api.g_varchar2_table(144) := '202020202020207D0A0A202020202020202020202020746869732E6F7074696F6E732E676574436F6D6D656E747328737563636573732C206572726F72293B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E744D6F64';
wwv_flow_api.g_varchar2_table(145) := '656C3A2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E6170706C79496E7465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A';
wwv_flow_api.g_varchar2_table(146) := '202020202020202020202020636F6D6D656E744D6F64656C2E6368696C6473203D205B5D3B0A202020202020202020202020636F6D6D656E744D6F64656C2E6861734174746163686D656E7473203D2066756E6374696F6E2829207B0A20202020202020';
wwv_flow_api.g_varchar2_table(147) := '20202020202020202072657475726E20636F6D6D656E744D6F64656C2E6174746163686D656E74732E6C656E677468203E20303B0A2020202020202020202020207D0A20202020202020202020202072657475726E20636F6D6D656E744D6F64656C3B0A';
wwv_flow_api.g_varchar2_table(148) := '20202020202020207D2C0A0A2020202020202020616464436F6D6D656E74546F446174614D6F64656C3A2066756E6374696F6E28636F6D6D656E744D6F64656C29207B0A2020202020202020202020206966282128636F6D6D656E744D6F64656C2E6964';
wwv_flow_api.g_varchar2_table(149) := '20696E20746869732E636F6D6D656E7473427949642929207B0A20202020202020202020202020202020746869732E636F6D6D656E7473427949645B636F6D6D656E744D6F64656C2E69645D203D20636F6D6D656E744D6F64656C3B0A0A202020202020';
wwv_flow_api.g_varchar2_table(150) := '202020202020202020202F2F20557064617465206368696C64206172726179206F662074686520706172656E742028617070656E64206368696C647320746F20746865206172726179206F66206F75746572206D6F737420706172656E74290A20202020';
wwv_flow_api.g_varchar2_table(151) := '202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A2020202020202020202020202020202020202020766172206F757465726D6F7374506172656E74203D20746869732E6765744F757465726D6F7374506172';
wwv_flow_api.g_varchar2_table(152) := '656E7428636F6D6D656E744D6F64656C2E706172656E74293B0A20202020202020202020202020202020202020206F757465726D6F7374506172656E742E6368696C64732E7075736828636F6D6D656E744D6F64656C2E6964293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(153) := '20202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020757064617465436F6D6D656E744D6F64656C3A2066756E6374696F6E28636F6D6D656E744D6F64656C29207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(154) := '20242E657874656E6428746869732E636F6D6D656E7473427949645B636F6D6D656E744D6F64656C2E69645D2C20636F6D6D656E744D6F64656C293B0A20202020202020207D2C0A0A202020202020202072656E6465723A2066756E6374696F6E282920';
wwv_flow_api.g_varchar2_table(155) := '7B0A2020202020202020202020207661722073656C66203D20746869733B0A0A2020202020202020202020202F2F2050726576656E742072652D72656E646572696E672069662064617461206861736E2774206265656E20666574636865640A20202020';
wwv_flow_api.g_varchar2_table(156) := '202020202020202069662821746869732E6461746146657463686564292072657475726E3B0A0A2020202020202020202020202F2F2053686F772061637469766520636F6E7461696E65720A202020202020202020202020746869732E73686F77416374';
wwv_flow_api.g_varchar2_table(157) := '697665436F6E7461696E657228293B0A0A2020202020202020202020202F2F2043726561746520636F6D6D656E747320616E64206174746163686D656E74730A202020202020202020202020746869732E637265617465436F6D6D656E747328293B0A20';
wwv_flow_api.g_varchar2_table(158) := '2020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747320262620746869732E6F7074696F6E732E656E61626C654E617669676174696F6E2920746869732E6372656174654174746163686D656E74';
wwv_flow_api.g_varchar2_table(159) := '7328293B0A0A2020202020202020202020202F2F2052656D6F7665207370696E6E65720A202020202020202020202020746869732E24656C2E66696E6428273E202E7370696E6E657227292E72656D6F766528293B0A0A20202020202020202020202074';
wwv_flow_api.g_varchar2_table(160) := '6869732E6F7074696F6E732E7265667265736828293B0A20202020202020207D2C0A0A202020202020202073686F77416374697665436F6E7461696E65723A2066756E6374696F6E2829207B0A202020202020202020202020766172206163746976654E';
wwv_flow_api.g_varchar2_table(161) := '617669676174696F6E456C203D20746869732E24656C2E66696E6428272E6E617669676174696F6E206C695B646174612D636F6E7461696E65722D6E616D655D2E61637469766527293B0A20202020202020202020202076617220636F6E7461696E6572';
wwv_flow_api.g_varchar2_table(162) := '4E616D65203D206163746976654E617669676174696F6E456C2E646174612827636F6E7461696E65722D6E616D6527293B0A20202020202020202020202076617220636F6E7461696E6572456C203D20746869732E24656C2E66696E6428275B64617461';
wwv_flow_api.g_varchar2_table(163) := '2D636F6E7461696E65723D2227202B20636F6E7461696E65724E616D65202B2027225D27293B0A202020202020202020202020636F6E7461696E6572456C2E7369626C696E677328275B646174612D636F6E7461696E65725D27292E6869646528293B0A';
wwv_flow_api.g_varchar2_table(164) := '202020202020202020202020636F6E7461696E6572456C2E73686F7728293B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E74733A2066756E6374696F6E2829207B0A2020202020202020202020207661722073656C';
wwv_flow_api.g_varchar2_table(165) := '66203D20746869733B0A0A2020202020202020202020202F2F2043726561746520746865206C69737420656C656D656E74206265666F726520617070656E64696E6720746F20444F4D20696E206F7264657220746F207265616368206265747465722070';
wwv_flow_api.g_varchar2_table(166) := '6572666F726D616E63650A202020202020202020202020746869732E24656C2E66696E64282723636F6D6D656E742D6C69737427292E72656D6F766528293B0A20202020202020202020202076617220636F6D6D656E744C697374203D202428273C756C';
wwv_flow_api.g_varchar2_table(167) := '2F3E272C207B0A2020202020202020202020202020202069643A2027636F6D6D656E742D6C697374272C0A2020202020202020202020202020202027636C617373273A20276D61696E270A2020202020202020202020207D293B0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(168) := '202020202F2F2044697669646520636F6D6D6D656E747320696E746F206D61696E206C6576656C20636F6D6D656E747320616E64207265706C6965730A202020202020202020202020766172206D61696E4C6576656C436F6D6D656E7473203D205B5D3B';
wwv_flow_api.g_varchar2_table(169) := '0A202020202020202020202020766172207265706C696573203D205B5D3B0A2020202020202020202020202428746869732E676574436F6D6D656E74732829292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C2920';
wwv_flow_api.g_varchar2_table(170) := '7B0A20202020202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E74203D3D206E756C6C29207B0A20202020202020202020202020202020202020206D61696E4C6576656C436F6D6D656E74732E7075736828636F6D6D65';
wwv_flow_api.g_varchar2_table(171) := '6E744D6F64656C293B0A202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020207265706C6965732E7075736828636F6D6D656E744D6F64656C293B0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(172) := '0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20417070656E64206D61696E206C6576656C20636F6D6D656E74730A202020202020202020202020746869732E736F7274436F6D6D656E7473286D61696E4C6576656C43';
wwv_flow_api.g_varchar2_table(173) := '6F6D6D656E74732C20746869732E63757272656E74536F72744B6579293B0A20202020202020202020202024286D61696E4C6576656C436F6D6D656E7473292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B';
wwv_flow_api.g_varchar2_table(174) := '0A2020202020202020202020202020202073656C662E616464436F6D6D656E7428636F6D6D656E744D6F64656C2C20636F6D6D656E744C697374293B0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20417070656E6420';
wwv_flow_api.g_varchar2_table(175) := '7265706C69657320696E206368726F6E6F6C6F676963616C206F726465720A202020202020202020202020746869732E736F7274436F6D6D656E7473287265706C6965732C20276F6C6465737427293B0A20202020202020202020202024287265706C69';
wwv_flow_api.g_varchar2_table(176) := '6573292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B0A2020202020202020202020202020202073656C662E616464436F6D6D656E7428636F6D6D656E744D6F64656C2C20636F6D6D656E744C697374293B';
wwv_flow_api.g_varchar2_table(177) := '0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20417070656E64206C69737420746F20444F4D0A202020202020202020202020746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D22636F6D6D';
wwv_flow_api.g_varchar2_table(178) := '656E7473225D27292E70726570656E6428636F6D6D656E744C697374293B0A20202020202020207D2C0A0A20202020202020206372656174654174746163686D656E74733A2066756E6374696F6E2829207B0A2020202020202020202020207661722073';
wwv_flow_api.g_varchar2_table(179) := '656C66203D20746869733B0A0A2020202020202020202020202F2F2043726561746520746865206C69737420656C656D656E74206265666F726520617070656E64696E6720746F20444F4D20696E206F7264657220746F20726561636820626574746572';
wwv_flow_api.g_varchar2_table(180) := '20706572666F726D616E63650A202020202020202020202020746869732E24656C2E66696E642827236174746163686D656E742D6C69737427292E72656D6F766528293B0A202020202020202020202020766172206174746163686D656E744C69737420';
wwv_flow_api.g_varchar2_table(181) := '3D202428273C756C2F3E272C207B0A2020202020202020202020202020202069643A20276174746163686D656E742D6C697374272C0A2020202020202020202020202020202027636C617373273A20276D61696E270A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(182) := '3B0A0A202020202020202020202020766172206174746163686D656E7473203D20746869732E6765744174746163686D656E747328293B0A202020202020202020202020746869732E736F7274436F6D6D656E7473286174746163686D656E74732C2027';
wwv_flow_api.g_varchar2_table(183) := '6E657765737427293B0A20202020202020202020202024286174746163686D656E7473292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B0A2020202020202020202020202020202073656C662E6164644174';
wwv_flow_api.g_varchar2_table(184) := '746163686D656E7428636F6D6D656E744D6F64656C2C206174746163686D656E744C697374293B0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204170706E6564206C69737420746F20444F4D0A202020202020202020';
wwv_flow_api.g_varchar2_table(185) := '202020746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D226174746163686D656E7473225D27292E70726570656E64286174746163686D656E744C697374293B0A20202020202020207D2C0A0A202020202020202061646443';
wwv_flow_api.g_varchar2_table(186) := '6F6D6D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2C20636F6D6D656E744C6973742C2070726570656E64436F6D6D656E7429207B202F2F4D4F44494649454420524943484152442042414C444F47490A2020202020202020202020';
wwv_flow_api.g_varchar2_table(187) := '20636F6D6D656E744C697374203D20636F6D6D656E744C697374207C7C20746869732E24656C2E66696E64282723636F6D6D656E742D6C69737427293B0A20202020202020202020202076617220636F6D6D656E74456C203D20746869732E6372656174';
wwv_flow_api.g_varchar2_table(188) := '65436F6D6D656E74456C656D656E7428636F6D6D656E744D6F64656C293B0A0A2020202020202020202020202F2F20436173653A207265706C790A202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A202020';
wwv_flow_api.g_varchar2_table(189) := '2020202020202020202020202076617220646972656374506172656E74456C203D20636F6D6D656E744C6973742E66696E6428272E636F6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E706172656E742B27225D27293B0A20';
wwv_flow_api.g_varchar2_table(190) := '202020202020202020202020202020766172206368696C64496E64656E64203D207061727365496E7428646972656374506172656E74456C2E637373282270616464696E672D6C656674222929202B2032353B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(191) := '766172207265706C696573203D20646972656374506172656E74456C2E66696E6428272E6368696C642D636F6D6D656E747327292E6368696C6472656E28276C692E636F6D6D656E7427293B0A20202020202020202020202020202020766172206C6173';
wwv_flow_api.g_varchar2_table(192) := '745265706C793B0A0A202020202020202020202020202020202F2F2052652D72656E64657220616374696F6E20626172206F662064697265637420706172656E7420656C656D656E740A20202020202020202020202020202020746869732E726552656E';
wwv_flow_api.g_varchar2_table(193) := '646572436F6D6D656E74416374696F6E42617228636F6D6D656E744D6F64656C2E706172656E74293B0A0A202020202020202020202020202020202F2F20466F726365207265706C69657320696E746F206F6E65206C6576656C206F6E6C790A20202020';
wwv_flow_api.g_varchar2_table(194) := '202020202020202020202020766172206F757465724D6F7374506172656E74203D20646972656374506172656E74456C2E706172656E747328272E636F6D6D656E7427292E6C61737428293B0A202020202020202020202020202020206966286F757465';
wwv_flow_api.g_varchar2_table(195) := '724D6F7374506172656E742E6C656E677468203D3D203029206F757465724D6F7374506172656E74203D20646972656374506172656E74456C3B0A0A20202020202020202020202020202020636F6D6D656E74456C2E637373282270616464696E672D6C';
wwv_flow_api.g_varchar2_table(196) := '656674222C206368696C64496E64656E64202B2022707822293B0A0A202020202020202020202020202020202F2F64657465726D696E65207768657468657220746865207265706C792073686F756C6420626520617070656E646564206469726563746C';
wwv_flow_api.g_varchar2_table(197) := '7920756E64657220746865206D61696E20636F6D6D656E74206F720A202020202020202020202020202020202F2F617320746865206C61737420656C656D656E74206F66207265706C6965730A2020202020202020202020202020202069662028726570';
wwv_flow_api.g_varchar2_table(198) := '6C6965732E6C656E67746829207B0A20202020202020202020202020202020202020206C6173745265706C79203D207265706C6965732E6C61737428293B0A20202020202020202020202020202020202020206C6173745265706C792E61667465722863';
wwv_flow_api.g_varchar2_table(199) := '6F6D6D656E74456C293B0A202020202020202020202020202020207D0A20202020202020202020202020202020656C7365207B0A20202020202020202020202020202020202020206C6173745265706C79203D20646972656374506172656E74456C2E66';
wwv_flow_api.g_varchar2_table(200) := '696E6428272E6368696C642D636F6D6D656E747327293B0A20202020202020202020202020202020202020206C6173745265706C792E70726570656E6428636F6D6D656E74456C293B0A202020202020202020202020202020207D0A0A20202020202020';
wwv_flow_api.g_varchar2_table(201) := '2020202020202020202F2F2055706461746520746F67676C6520616C6C202D627574746F6E0A20202020202020202020202020202020746869732E757064617465546F67676C65416C6C427574746F6E286F757465724D6F7374506172656E74293B0A0A';
wwv_flow_api.g_varchar2_table(202) := '2020202020202020202020202F2F20436173653A206D61696E206C6576656C20636F6D6D656E740A2020202020202020202020207D20656C7365207B0A0A20202020202020202020202020202020636F6D6D656E74456C2E637373282270616464696E67';
wwv_flow_api.g_varchar2_table(203) := '2D6C656674222C202230707822293B0A0A2020202020202020202020202020202069662870726570656E64436F6D6D656E7429207B0A2020202020202020202020202020202020202020636F6D6D656E744C6973742E70726570656E6428636F6D6D656E';
wwv_flow_api.g_varchar2_table(204) := '74456C293B0A202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020636F6D6D656E744C6973742E617070656E6428636F6D6D656E74456C293B0A202020202020202020202020202020207D0A';
wwv_flow_api.g_varchar2_table(205) := '2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020206164644174746163686D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2C20636F6D6D656E744C69737429207B0A20202020202020202020202063';
wwv_flow_api.g_varchar2_table(206) := '6F6D6D656E744C697374203D20636F6D6D656E744C697374207C7C20746869732E24656C2E66696E642827236174746163686D656E742D6C69737427293B0A20202020202020202020202076617220636F6D6D656E74456C203D20746869732E63726561';
wwv_flow_api.g_varchar2_table(207) := '7465436F6D6D656E74456C656D656E7428636F6D6D656E744D6F64656C293B0A202020202020202020202020636F6D6D656E744C6973742E70726570656E6428636F6D6D656E74456C293B0A20202020202020207D2C0A0A202020202020202072656D6F';
wwv_flow_api.g_varchar2_table(208) := '7665436F6D6D656E743A2066756E6374696F6E28636F6D6D656E74496429207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E636F';
wwv_flow_api.g_varchar2_table(209) := '6D6D656E7473427949645B636F6D6D656E7449645D3B0A0A2020202020202020202020202F2F2052656D6F7665206368696C6420636F6D6D656E7473207265637572736976656C790A202020202020202020202020766172206368696C64436F6D6D656E';
wwv_flow_api.g_varchar2_table(210) := '7473203D20746869732E6765744368696C64436F6D6D656E747328636F6D6D656E744D6F64656C2E6964293B0A20202020202020202020202024286368696C64436F6D6D656E7473292E656163682866756E6374696F6E28696E6465782C206368696C64';
wwv_flow_api.g_varchar2_table(211) := '436F6D6D656E7429207B0A2020202020202020202020202020202073656C662E72656D6F7665436F6D6D656E74286368696C64436F6D6D656E742E6964293B0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2055706461';
wwv_flow_api.g_varchar2_table(212) := '746520746865206368696C64206172726179206F66206F757465726D6F737420706172656E740A202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A20202020202020202020202020202020766172206F7574';
wwv_flow_api.g_varchar2_table(213) := '65726D6F7374506172656E74203D20746869732E6765744F757465726D6F7374506172656E7428636F6D6D656E744D6F64656C2E706172656E74293B0A2020202020202020202020202020202076617220696E646578546F52656D6F7665203D206F7574';
wwv_flow_api.g_varchar2_table(214) := '65726D6F7374506172656E742E6368696C64732E696E6465784F6628636F6D6D656E744D6F64656C2E6964293B0A202020202020202020202020202020206F757465726D6F7374506172656E742E6368696C64732E73706C69636528696E646578546F52';
wwv_flow_api.g_varchar2_table(215) := '656D6F76652C2031293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2052656D6F76652074686520636F6D6D656E742066726F6D2064617461206D6F64656C0A20202020202020202020202064656C65746520746869732E';
wwv_flow_api.g_varchar2_table(216) := '636F6D6D656E7473427949645B636F6D6D656E7449645D3B0A0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B636F6D';
wwv_flow_api.g_varchar2_table(217) := '6D656E7449642B27225D27293B0A20202020202020202020202076617220706172656E74456C203D20636F6D6D656E74456C656D656E74732E706172656E747328276C692E636F6D6D656E7427292E6C61737428293B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(218) := '2F2F2052656D6F76652074686520656C656D656E740A202020202020202020202020636F6D6D656E74456C656D656E74732E72656D6F766528293B0A0A2020202020202020202020202F2F205570646174652074686520746F67676C6520616C6C206275';
wwv_flow_api.g_varchar2_table(219) := '74746F6E0A202020202020202020202020746869732E757064617465546F67676C65416C6C427574746F6E28706172656E74456C293B0A20202020202020207D2C0A0A202020202020202070726544656C6574654174746163686D656E743A2066756E63';
wwv_flow_api.g_varchar2_table(220) := '74696F6E28657629207B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D20242865762E63757272656E74546172676574292E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428';
wwv_flow_api.g_varchar2_table(221) := '290A202020202020202020202020766172206174746163686D656E74456C203D20242865762E63757272656E74546172676574292E706172656E747328272E6174746163686D656E7427292E666972737428293B0A202020202020202020202020617474';
wwv_flow_api.g_varchar2_table(222) := '6163686D656E74456C2E72656D6F766528293B0A0A2020202020202020202020202F2F20436865636B206966207361766520627574746F6E206E6565647320746F20626520656E61626C65640A202020202020202020202020746869732E746F67676C65';
wwv_flow_api.g_varchar2_table(223) := '53617665427574746F6E28636F6D6D656E74696E674669656C64293B0A20202020202020207D2C0A0A2020202020202020707265536176654174746163686D656E74733A2066756E6374696F6E2866696C65732C20636F6D6D656E74696E674669656C64';
wwv_flow_api.g_varchar2_table(224) := '29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202069662866696C65732E6C656E67746829207B0A0A202020202020202020202020202020202F2F20456C656D656E74730A202020202020';
wwv_flow_api.g_varchar2_table(225) := '2020202020202020202069662821636F6D6D656E74696E674669656C642920636F6D6D656E74696E674669656C64203D20746869732E24656C2E66696E6428272E636F6D6D656E74696E672D6669656C642E6D61696E27293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(226) := '2020202020207661722075706C6F6164427574746F6E203D20636F6D6D656E74696E674669656C642E66696E6428272E636F6E74726F6C2D726F77202E75706C6F616427293B0A202020202020202020202020202020207661722069735265706C79203D';
wwv_flow_api.g_varchar2_table(227) := '2021636F6D6D656E74696E674669656C642E686173436C61737328276D61696E27293B0A20202020202020202020202020202020766172206174746163686D656E7473436F6E7461696E6572203D20636F6D6D656E74696E674669656C642E66696E6428';
wwv_flow_api.g_varchar2_table(228) := '272E636F6E74726F6C2D726F77202E6174746163686D656E747327293B0A0A202020202020202020202020202020202F2F20437265617465206174746163686D656E74206D6F64656C730A20202020202020202020202020202020766172206174746163';
wwv_flow_api.g_varchar2_table(229) := '686D656E7473203D20242866696C6573292E6D61702866756E6374696F6E28696E6465782C2066696C65297B0A202020202020202020202020202020202020202072657475726E207B0A2020202020202020202020202020202020202020202020206D69';
wwv_flow_api.g_varchar2_table(230) := '6D655F747970653A2066696C652E747970652C0A20202020202020202020202020202020202020202020202066696C653A2066696C650A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D293B0A0A2020';
wwv_flow_api.g_varchar2_table(231) := '20202020202020202020202020202F2F2046696C746572206F757420616C7265616479206164646564206174746163686D656E74730A20202020202020202020202020202020766172206578697374696E674174746163686D656E7473203D2074686973';
wwv_flow_api.g_varchar2_table(232) := '2E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C6428636F6D6D656E74696E674669656C64293B0A202020202020202020202020202020206174746163686D656E7473203D206174746163686D656E74732E66696C7465';
wwv_flow_api.g_varchar2_table(233) := '722866756E6374696F6E28696E6465782C206174746163686D656E7429207B0A2020202020202020202020202020202020202020766172206475706C6963617465203D2066616C73653B0A0A20202020202020202020202020202020202020202F2F2043';
wwv_flow_api.g_varchar2_table(234) := '6865636B206966207468652061747461636D656E74206E616D6520616E642073697A65206D617463686573207769746820616C7265616479206164646564206174746163686D656E740A2020202020202020202020202020202020202020242865786973';
wwv_flow_api.g_varchar2_table(235) := '74696E674174746163686D656E7473292E656163682866756E6374696F6E28696E6465782C206578697374696E674174746163686D656E7429207B0A2020202020202020202020202020202020202020202020206966286174746163686D656E742E6669';
wwv_flow_api.g_varchar2_table(236) := '6C652E6E616D65203D3D206578697374696E674174746163686D656E742E66696C652E6E616D65202626206174746163686D656E742E66696C652E73697A65203D3D206578697374696E674174746163686D656E742E66696C652E73697A6529207B0A20';
wwv_flow_api.g_varchar2_table(237) := '2020202020202020202020202020202020202020202020202020206475706C6963617465203D20747275653B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D293B0A0A20202020';
wwv_flow_api.g_varchar2_table(238) := '2020202020202020202020202020202072657475726E20216475706C69636174653B0A202020202020202020202020202020207D293B0A0A202020202020202020202020202020202F2F20456E73757265207468617420746865206D61696E20636F6D6D';
wwv_flow_api.g_varchar2_table(239) := '656E74696E67206669656C642069732073686F776E206966206174746163686D656E7473207765726520616464656420746F20746861740A20202020202020202020202020202020696628636F6D6D656E74696E674669656C642E686173436C61737328';
wwv_flow_api.g_varchar2_table(240) := '276D61696E272929207B0A2020202020202020202020202020202020202020636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127292E747269676765722827636C69636B27293B0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(241) := '0A0A202020202020202020202020202020202F2F2053657420627574746F6E20737461746520746F206C6F6164696E670A20202020202020202020202020202020746869732E736574427574746F6E53746174652875706C6F6164427574746F6E2C2066';
wwv_flow_api.g_varchar2_table(242) := '616C73652C2074727565293B0A0A202020202020202020202020202020202F2F2056616C6964617465206174746163686D656E74730A20202020202020202020202020202020746869732E6F7074696F6E732E76616C69646174654174746163686D656E';
wwv_flow_api.g_varchar2_table(243) := '7473286174746163686D656E74732C2066756E6374696F6E2876616C6964617465644174746163686D656E747329207B0A0A202020202020202020202020202020202020202069662876616C6964617465644174746163686D656E74732E6C656E677468';
wwv_flow_api.g_varchar2_table(244) := '29C2A07B0A0A2020202020202020202020202020202020202020202020202F2F20437265617465206174746163686D656E7420746167730A202020202020202020202020202020202020202020202020242876616C6964617465644174746163686D656E';
wwv_flow_api.g_varchar2_table(245) := '7473292E656163682866756E6374696F6E28696E6465782C206174746163686D656E7429207B0A20202020202020202020202020202020202020202020202020202020766172206174746163686D656E74546167203D2073656C662E6372656174654174';
wwv_flow_api.g_varchar2_table(246) := '746163686D656E74546167456C656D656E74286174746163686D656E742C2074727565293B0A202020202020202020202020202020202020202020202020202020206174746163686D656E7473436F6E7461696E65722E617070656E6428617474616368';
wwv_flow_api.g_varchar2_table(247) := '6D656E74546167293B0A2020202020202020202020202020202020202020202020207D293B0A0A2020202020202020202020202020202020202020202020202F2F20436865636B206966207361766520627574746F6E206E6565647320746F2062652065';
wwv_flow_api.g_varchar2_table(248) := '6E61626C65640A20202020202020202020202020202020202020202020202073656C662E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64293B0A20202020202020202020202020202020202020207D0A0A202020202020';
wwv_flow_api.g_varchar2_table(249) := '20202020202020202020202020202F2F20526573657420627574746F6E2073746174650A202020202020202020202020202020202020202073656C662E736574427574746F6E53746174652875706C6F6164427574746F6E2C20747275652C2066616C73';
wwv_flow_api.g_varchar2_table(250) := '65293B0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20436C6561722074686520696E707574206669656C640A20202020202020202020202075706C6F6164427574746F6E';
wwv_flow_api.g_varchar2_table(251) := '2E66696E642827696E70757427292E76616C282727293B0A20202020202020207D2C0A0A2020202020202020757064617465546F67676C65416C6C427574746F6E3A2066756E6374696F6E28706172656E74456C29207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(252) := '2F2F20446F6E27742068696465207265706C696573206966206D61785265706C69657356697369626C65206973206E756C6C206F7220756E646566696E65640A20202020202020202020202069662028746869732E6F7074696F6E732E6D61785265706C';
wwv_flow_api.g_varchar2_table(253) := '69657356697369626C65203D3D206E756C6C292072657475726E3B0A0A202020202020202020202020766172206368696C64436F6D6D656E7473456C203D20706172656E74456C2E66696E6428272E6368696C642D636F6D6D656E747327293B0A202020';
wwv_flow_api.g_varchar2_table(254) := '202020202020202020766172206368696C64436F6D6D656E7473203D206368696C64436F6D6D656E7473456C2E66696E6428272E636F6D6D656E7427292E6E6F7428272E68696464656E27293B0A20202020202020202020202076617220746F67676C65';
wwv_flow_api.g_varchar2_table(255) := '416C6C427574746F6E203D206368696C64436F6D6D656E7473456C2E66696E6428276C692E746F67676C652D616C6C27293B0A2020202020202020202020206368696C64436F6D6D656E74732E72656D6F7665436C6173732827746F67676C61626C652D';
wwv_flow_api.g_varchar2_table(256) := '7265706C7927293B0A0A2020202020202020202020202F2F2053656C656374207265706C69657320746F2062652068696464656E0A20202020202020202020202069662028746869732E6F7074696F6E732E6D61785265706C69657356697369626C6520';
wwv_flow_api.g_varchar2_table(257) := '3D3D3D203029207B0A2020202020202020202020202020202076617220746F67676C61626C655265706C696573203D206368696C64436F6D6D656E74733B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(258) := '76617220746F67676C61626C655265706C696573203D206368696C64436F6D6D656E74732E736C69636528302C202D746869732E6F7074696F6E732E6D61785265706C69657356697369626C65293B0A2020202020202020202020207D0A0A2020202020';
wwv_flow_api.g_varchar2_table(259) := '202020202020202F2F20416464206964656E74696679696E6720636C61737320666F722068696464656E207265706C69657320736F20746865792063616E20626520746F67676C65640A202020202020202020202020746F67676C61626C655265706C69';
wwv_flow_api.g_varchar2_table(260) := '65732E616464436C6173732827746F67676C61626C652D7265706C7927293B0A0A2020202020202020202020202F2F2053686F7720616C6C207265706C696573206966207265706C6965732061726520657870616E6465640A2020202020202020202020';
wwv_flow_api.g_varchar2_table(261) := '20696628746F67676C65416C6C427574746F6E2E66696E6428277370616E2E7465787427292E746578742829203D3D20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E686964655265706C69657354';
wwv_flow_api.g_varchar2_table(262) := '6578742929207B0A20202020202020202020202020202020746F67676C61626C655265706C6965732E616464436C617373282776697369626C6527293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F204D616B6520737572';
wwv_flow_api.g_varchar2_table(263) := '65207468617420746F67676C6520616C6C20627574746F6E2069732070726573656E740A2020202020202020202020206966286368696C64436F6D6D656E74732E6C656E677468203E20746869732E6F7074696F6E732E6D61785265706C696573566973';
wwv_flow_api.g_varchar2_table(264) := '69626C6529207B0A0A202020202020202020202020202020202F2F20417070656E6420627574746F6E20746F20746F67676C6520616C6C207265706C696573206966206E65636573736172790A2020202020202020202020202020202069662821746F67';
wwv_flow_api.g_varchar2_table(265) := '676C65416C6C427574746F6E2E6C656E67746829207B0A0A2020202020202020202020202020202020202020746F67676C65416C6C427574746F6E203D202428273C6C692F3E272C207B0A20202020202020202020202020202020202020202020202027';
wwv_flow_api.g_varchar2_table(266) := '636C617373273A2027746F67676C652D616C6C20686967686C696768742D666F6E742D626F6C64270A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020202020202076617220746F67676C65416C6C4275';
wwv_flow_api.g_varchar2_table(267) := '74746F6E54657874203D202428273C7370616E2F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A202774657874270A20202020202020202020202020202020202020207D293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(268) := '20202020202020202020766172206361726574203D202428273C7370616E2F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A20276361726574270A20202020202020202020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(269) := '3B0A0A20202020202020202020202020202020202020202F2F20417070656E6420746F67676C6520627574746F6E20746F20444F4D0A2020202020202020202020202020202020202020746F67676C65416C6C427574746F6E2E617070656E6428746F67';
wwv_flow_api.g_varchar2_table(270) := '676C65416C6C427574746F6E54657874292E617070656E64286361726574293B0A20202020202020202020202020202020202020206368696C64436F6D6D656E7473456C2E70726570656E6428746F67676C65416C6C427574746F6E293B0A2020202020';
wwv_flow_api.g_varchar2_table(271) := '20202020202020202020207D0A0A202020202020202020202020202020202F2F20557064617465207468652074657874206F6620746F67676C6520616C6C202D627574746F6E0A20202020202020202020202020202020746869732E736574546F67676C';
wwv_flow_api.g_varchar2_table(272) := '65416C6C427574746F6E5465787428746F67676C65416C6C427574746F6E2C2066616C7365293B0A0A2020202020202020202020202F2F204D616B652073757265207468617420746F67676C6520616C6C20627574746F6E206973206E6F742070726573';
wwv_flow_api.g_varchar2_table(273) := '656E740A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020746F67676C65416C6C427574746F6E2E72656D6F766528293B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020';
wwv_flow_api.g_varchar2_table(274) := '20757064617465546F67676C65416C6C427574746F6E733A2066756E6374696F6E2829207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220636F6D6D656E744C697374203D20746869';
wwv_flow_api.g_varchar2_table(275) := '732E24656C2E66696E64282723636F6D6D656E742D6C69737427293B0A0A2020202020202020202020202F2F20466F6C6420636F6D6D656E74732C2066696E64206669727374206C6576656C206368696C6472656E20616E642075706461746520746F67';
wwv_flow_api.g_varchar2_table(276) := '676C6520627574746F6E730A202020202020202020202020636F6D6D656E744C6973742E66696E6428272E636F6D6D656E7427292E72656D6F7665436C617373282776697369626C6527293B0A202020202020202020202020636F6D6D656E744C697374';
wwv_flow_api.g_varchar2_table(277) := '2E6368696C6472656E28272E636F6D6D656E7427292E656163682866756E6374696F6E28696E6465782C20656C29207B0A2020202020202020202020202020202073656C662E757064617465546F67676C65416C6C427574746F6E282428656C29293B0A';
wwv_flow_api.g_varchar2_table(278) := '2020202020202020202020207D293B0A20202020202020207D2C0A0A2020202020202020736F7274436F6D6D656E74733A2066756E6374696F6E2028636F6D6D656E74732C20736F72744B657929207B0A2020202020202020202020207661722073656C';
wwv_flow_api.g_varchar2_table(279) := '66203D20746869733B0A0A2020202020202020202020202F2F20536F727420627920706F70756C61726974790A202020202020202020202020696628736F72744B6579203D3D2027706F70756C61726974792729207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(280) := '202020636F6D6D656E74732E736F72742866756E6374696F6E28636F6D6D656E74412C20636F6D6D656E744229207B0A202020202020202020202020202020202020202076617220706F696E74734F6641203D20636F6D6D656E74412E6368696C64732E';
wwv_flow_api.g_varchar2_table(281) := '6C656E6774683B0A202020202020202020202020202020202020202076617220706F696E74734F6642203D20636F6D6D656E74422E6368696C64732E6C656E6774683B0A0A202020202020202020202020202020202020202069662873656C662E6F7074';
wwv_flow_api.g_varchar2_table(282) := '696F6E732E656E61626C655570766F74696E6729207B0A202020202020202020202020202020202020202020202020706F696E74734F6641202B3D20636F6D6D656E74412E7570766F7465436F756E743B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(283) := '202020202020706F696E74734F6642202B3D20636F6D6D656E74422E7570766F7465436F756E743B0A20202020202020202020202020202020202020207D0A0A2020202020202020202020202020202020202020696628706F696E74734F664220213D20';
wwv_flow_api.g_varchar2_table(284) := '706F696E74734F664129207B0A20202020202020202020202020202020202020202020202072657475726E20706F696E74734F6642202D20706F696E74734F66413B0A0A20202020202020202020202020202020202020207D20656C7365207B0A202020';
wwv_flow_api.g_varchar2_table(285) := '2020202020202020202020202020202020202020202F2F2052657475726E206E6577657220696620706F70756C6172697479206973207468652073616D650A20202020202020202020202020202020202020202020202076617220637265617465644120';
wwv_flow_api.g_varchar2_table(286) := '3D206E6577204461746528636F6D6D656E74412E63726561746564292E67657454696D6528293B0A202020202020202020202020202020202020202020202020766172206372656174656442203D206E6577204461746528636F6D6D656E74422E637265';
wwv_flow_api.g_varchar2_table(287) := '61746564292E67657454696D6528293B0A20202020202020202020202020202020202020202020202072657475726E206372656174656442202D2063726561746564413B0A20202020202020202020202020202020202020207D0A202020202020202020';
wwv_flow_api.g_varchar2_table(288) := '202020202020207D293B0A0A2020202020202020202020202F2F20536F727420627920646174650A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020636F6D6D656E74732E736F72742866756E6374696F6E28';
wwv_flow_api.g_varchar2_table(289) := '636F6D6D656E74412C20636F6D6D656E744229207B0A2020202020202020202020202020202020202020766172206372656174656441203D206E6577204461746528636F6D6D656E74412E63726561746564292E67657454696D6528293B0A2020202020';
wwv_flow_api.g_varchar2_table(290) := '202020202020202020202020202020766172206372656174656442203D206E6577204461746528636F6D6D656E74422E63726561746564292E67657454696D6528293B0A2020202020202020202020202020202020202020696628736F72744B6579203D';
wwv_flow_api.g_varchar2_table(291) := '3D20276F6C646573742729207B0A20202020202020202020202020202020202020202020202072657475726E206372656174656441202D2063726561746564423B0A20202020202020202020202020202020202020207D20656C7365207B0A2020202020';
wwv_flow_api.g_varchar2_table(292) := '2020202020202020202020202020202020202072657475726E206372656174656442202D2063726561746564413B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(293) := '207D0A20202020202020207D2C0A0A2020202020202020736F7274416E645265417272616E6765436F6D6D656E74733A2066756E6374696F6E28736F72744B657929207B0A20202020202020202020202076617220636F6D6D656E744C697374203D2074';
wwv_flow_api.g_varchar2_table(294) := '6869732E24656C2E66696E64282723636F6D6D656E742D6C69737427293B0A0A2020202020202020202020202F2F20476574206D61696E206C6576656C20636F6D6D656E74730A202020202020202020202020766172206D61696E4C6576656C436F6D6D';
wwv_flow_api.g_varchar2_table(295) := '656E7473203D20746869732E676574436F6D6D656E747328292E66696C7465722866756E6374696F6E28636F6D6D656E744D6F64656C297B72657475726E2021636F6D6D656E744D6F64656C2E706172656E747D293B0A20202020202020202020202074';
wwv_flow_api.g_varchar2_table(296) := '6869732E736F7274436F6D6D656E7473286D61696E4C6576656C436F6D6D656E74732C20736F72744B6579293B0A0A2020202020202020202020202F2F205265617272616E676520746865206D61696E206C6576656C20636F6D6D656E74730A20202020';
wwv_flow_api.g_varchar2_table(297) := '202020202020202024286D61696E4C6576656C436F6D6D656E7473292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B0A2020202020202020202020202020202076617220636F6D6D656E74456C203D20636F';
wwv_flow_api.g_varchar2_table(298) := '6D6D656E744C6973742E66696E6428273E206C692E636F6D6D656E745B646174612D69643D272B636F6D6D656E744D6F64656C2E69642B275D27293B0A20202020202020202020202020202020636F6D6D656E744C6973742E617070656E6428636F6D6D';
wwv_flow_api.g_varchar2_table(299) := '656E74456C293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A202020202020202073686F77416374697665536F72743A2066756E6374696F6E2829207B0A20202020202020202020202076617220616374697665456C656D65';
wwv_flow_api.g_varchar2_table(300) := '6E7473203D20746869732E24656C2E66696E6428272E6E617669676174696F6E206C695B646174612D736F72742D6B65793D2227202B20746869732E63757272656E74536F72744B6579202B2027225D27293B0A0A2020202020202020202020202F2F20';
wwv_flow_api.g_varchar2_table(301) := '496E6469636174652061637469766520736F72740A202020202020202020202020746869732E24656C2E66696E6428272E6E617669676174696F6E206C6927292E72656D6F7665436C617373282761637469766527293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(302) := '616374697665456C656D656E74732E616464436C617373282761637469766527293B0A0A2020202020202020202020202F2F20557064617465207469746C6520666F722064726F70646F776E0A202020202020202020202020766172207469746C65456C';
wwv_flow_api.g_varchar2_table(303) := '203D20746869732E24656C2E66696E6428272E6E617669676174696F6E202E7469746C6527293B0A202020202020202020202020696628746869732E63757272656E74536F72744B657920213D20276174746163686D656E74732729207B0A2020202020';
wwv_flow_api.g_varchar2_table(304) := '20202020202020202020207469746C65456C2E616464436C617373282761637469766527293B0A202020202020202020202020202020207469746C65456C2E66696E64282768656164657227292E68746D6C28616374697665456C656D656E74732E6669';
wwv_flow_api.g_varchar2_table(305) := '72737428292E68746D6C2829293B0A202020202020202020202020207D20656C7365207B0A202020202020202020202020202020207661722064656661756C7444726F70646F776E456C203D20746869732E24656C2E66696E6428272E6E617669676174';
wwv_flow_api.g_varchar2_table(306) := '696F6E20756C2E64726F70646F776E27292E6368696C6472656E28292E666972737428293B0A202020202020202020202020202020207469746C65456C2E66696E64282768656164657227292E68746D6C2864656661756C7444726F70646F776E456C2E';
wwv_flow_api.g_varchar2_table(307) := '68746D6C2829293B0A202020202020202020202020207D0A0A2020202020202020202020202F2F2053686F772061637469766520636F6E7461696E65720A202020202020202020202020746869732E73686F77416374697665436F6E7461696E65722829';
wwv_flow_api.g_varchar2_table(308) := '3B0A20202020202020207D2C0A0A2020202020202020666F726365526573706F6E736976653A2066756E6374696F6E2829207B0A202020202020202020202020746869732E24656C2E616464436C6173732827726573706F6E7369766527293B0A202020';
wwv_flow_api.g_varchar2_table(309) := '20202020207D2C0A0A20202020202020202F2F204576656E742068616E646C6572730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A2020202020202020636C6F736544726F70646F776E733A2066756E6374696F6E2829207B0A20';
wwv_flow_api.g_varchar2_table(310) := '2020202020202020202020746869732E24656C2E66696E6428272E64726F70646F776E27292E6869646528293B0A20202020202020207D2C0A0A2020202020202020707265536176655061737465644174746163686D656E74733A2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(311) := '28657629207B0A20202020202020202020202076617220636C6970626F61726444617461203D2065762E6F726967696E616C4576656E742E636C6970626F617264446174613B0A2020202020202020202020207661722066696C6573203D20636C697062';
wwv_flow_api.g_varchar2_table(312) := '6F617264446174612E66696C65733B0A0A2020202020202020202020202F2F2042726F7773657273206F6E6C7920737570706F72742070617374696E67206F6E652066696C650A20202020202020202020202069662866696C65732026262066696C6573';
wwv_flow_api.g_varchar2_table(313) := '2E6C656E677468203D3D203129207B0A0A202020202020202020202020202020202F2F2053656C65637420636F727265637420636F6D6D656E74696E67206669656C640A2020202020202020202020202020202076617220636F6D6D656E74696E674669';
wwv_flow_api.g_varchar2_table(314) := '656C643B0A2020202020202020202020202020202076617220706172656E74436F6D6D656E74696E674669656C64203D20242865762E746172676574292E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B20';
wwv_flow_api.g_varchar2_table(315) := '0A20202020202020202020202020202020696628706172656E74436F6D6D656E74696E674669656C642E6C656E67746829207B0A2020202020202020202020202020202020202020636F6D6D656E74696E674669656C64203D20706172656E74436F6D6D';
wwv_flow_api.g_varchar2_table(316) := '656E74696E674669656C643B0A202020202020202020202020202020207D0A0A20202020202020202020202020202020746869732E707265536176654174746163686D656E74732866696C65732C20636F6D6D656E74696E674669656C64293B0A202020';
wwv_flow_api.g_varchar2_table(317) := '2020202020202020202020202065762E70726576656E7444656661756C7428293B0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020736176654F6E4B6579646F776E3A2066756E6374696F6E28657629207B0A2020';
wwv_flow_api.g_varchar2_table(318) := '202020202020202020202F2F205361766520636F6D6D656E74206F6E20636D642F6374726C202B20656E7465720A20202020202020202020202069662865762E6B6579436F6465203D3D20313329207B0A20202020202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(319) := '206D6574614B6579203D2065762E6D6574614B6579207C7C2065762E6374726C4B65793B0A20202020202020202020202020202020696628746869732E6F7074696F6E732E706F7374436F6D6D656E744F6E456E746572207C7C206D6574614B657929C2';
wwv_flow_api.g_varchar2_table(320) := 'A07B0A202020202020202020202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A2020202020202020202020202020202020202020656C2E7369626C696E677328272E636F6E74726F6C2D726F772729';
wwv_flow_api.g_varchar2_table(321) := '2E66696E6428272E7361766527292E747269676765722827636C69636B27293B0A202020202020202020202020202020202020202065762E73746F7050726F7061676174696F6E28293B0A202020202020202020202020202020202020202065762E7072';
wwv_flow_api.g_varchar2_table(322) := '6576656E7444656661756C7428293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020736176654564697461626C65436F6E74656E743A2066756E6374696F6E286576';
wwv_flow_api.g_varchar2_table(323) := '29207B0A20202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A202020202020202020202020656C2E6461746128276265666F7265272C20656C2E68746D6C2829293B0A20202020202020207D2C0A0A';
wwv_flow_api.g_varchar2_table(324) := '2020202020202020636865636B4564697461626C65436F6E74656E74466F724368616E67653A2066756E6374696F6E28657629207B0A20202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A0A202020';
wwv_flow_api.g_varchar2_table(325) := '2020202020202020202F2F20466978206A71756572792D74657874636F6D706C657465206F6E2049452C20656D7074792074657874206E6F6465732077696C6C20627265616B20757020746865206175746F636F6D706C65746520666561747572650A20';
wwv_flow_api.g_varchar2_table(326) := '20202020202020202020202428656C5B305D2E6368696C644E6F646573292E656163682866756E6374696F6E2829207B0A20202020202020202020202020202020696628746869732E6E6F646554797065203D3D204E6F64652E544558545F4E4F444520';
wwv_flow_api.g_varchar2_table(327) := '262620746869732E6C656E677468203D3D203020262620746869732E72656D6F76654E6F64652920746869732E72656D6F76654E6F646528293B0A2020202020202020202020207D293B0A0A20202020202020202020202069662028656C2E6461746128';
wwv_flow_api.g_varchar2_table(328) := '276265666F7265272920213D20656C2E68746D6C282929207B0A20202020202020202020202020202020656C2E6461746128276265666F7265272C20656C2E68746D6C2829293B0A20202020202020202020202020202020656C2E747269676765722827';
wwv_flow_api.g_varchar2_table(329) := '6368616E676527293B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020206E617669676174696F6E456C656D656E74436C69636B65643A2066756E6374696F6E28657629207B0A202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(330) := '206E617669676174696F6E456C203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220736F72744B6579203D206E617669676174696F6E456C2E6461746128292E736F72744B65793B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(331) := '20202020202F2F20536F72742074686520636F6D6D656E7473206966206E65636573736172790A202020202020202020202020696628736F72744B6579203D3D20276174746163686D656E74732729207B0A202020202020202020202020202020207468';
wwv_flow_api.g_varchar2_table(332) := '69732E6372656174654174746163686D656E747328293B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020746869732E736F7274416E645265417272616E6765436F6D6D656E747328736F72744B6579293B';
wwv_flow_api.g_varchar2_table(333) := '0A2020202020202020202020207D0A0A2020202020202020202020202F2F2053617665207468652063757272656E7420736F7274206B65790A202020202020202020202020746869732E63757272656E74536F72744B6579203D20736F72744B65793B0A';
wwv_flow_api.g_varchar2_table(334) := '202020202020202020202020746869732E73686F77416374697665536F727428293B0A20202020202020207D2C0A0A2020202020202020746F67676C654E617669676174696F6E44726F70646F776E3A2066756E6374696F6E28657629207B0A20202020';
wwv_flow_api.g_varchar2_table(335) := '20202020202020202F2F2050726576656E7420636C6F73696E6720696D6D6564696174656C790A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0A0A2020202020202020202020207661722064726F70646F776E203D';
wwv_flow_api.g_varchar2_table(336) := '20242865762E63757272656E74546172676574292E66696E6428277E202E64726F70646F776E27293B0A20202020202020202020202064726F70646F776E2E746F67676C6528293B0A20202020202020207D2C0A0A202020202020202073686F774D6169';
wwv_flow_api.g_varchar2_table(337) := '6E436F6D6D656E74696E674669656C643A2066756E6374696F6E28657629207B0A202020202020202020202020766172206D61696E5465787461726561203D20242865762E63757272656E74546172676574293B0A2020202020202020202020206D6169';
wwv_flow_api.g_varchar2_table(338) := '6E54657874617265612E7369626C696E677328272E636F6E74726F6C2D726F7727292E73686F7728293B0A2020202020202020202020206D61696E54657874617265612E706172656E7428292E66696E6428272E636C6F736527292E73686F7728293B0A';
wwv_flow_api.g_varchar2_table(339) := '2020202020202020202020206D61696E54657874617265612E706172656E7428292E66696E6428272E75706C6F61642E696E6C696E652D627574746F6E27292E6869646528293B0A2020202020202020202020206D61696E54657874617265612E666F63';
wwv_flow_api.g_varchar2_table(340) := '757328293B0A20202020202020207D2C0A0A2020202020202020686964654D61696E436F6D6D656E74696E674669656C643A2066756E6374696F6E28657629207B0A20202020202020202020202076617220636C6F7365427574746F6E203D2024286576';
wwv_flow_api.g_varchar2_table(341) := '2E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D20746869732E24656C2E66696E6428272E636F6D6D656E74696E672D6669656C642E6D61696E27293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(342) := '20202020766172206D61696E5465787461726561203D20636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127293B0A202020202020202020202020766172206D61696E436F6E74726F6C526F77203D20636F6D6D656E74696E';
wwv_flow_api.g_varchar2_table(343) := '674669656C642E66696E6428272E636F6E74726F6C2D726F7727293B0A0A2020202020202020202020202F2F20436C656172207465787420617265610A202020202020202020202020746869732E636C6561725465787461726561286D61696E54657874';
wwv_flow_api.g_varchar2_table(344) := '61726561293B0A0A2020202020202020202020202F2F20436C656172206174746163686D656E74730A202020202020202020202020636F6D6D656E74696E674669656C642E66696E6428272E6174746163686D656E747327292E656D70747928293B0A0A';
wwv_flow_api.g_varchar2_table(345) := '2020202020202020202020202F2F20546F67676C65207361766520627574746F6E0A202020202020202020202020746869732E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64293B0A0A2020202020202020202020202F';
wwv_flow_api.g_varchar2_table(346) := '2F2041646A757374206865696768740A202020202020202020202020746869732E61646A7573745465787461726561486569676874286D61696E54657874617265612C2066616C7365293B0A0A2020202020202020202020206D61696E436F6E74726F6C';
wwv_flow_api.g_varchar2_table(347) := '526F772E6869646528293B0A202020202020202020202020636C6F7365427574746F6E2E6869646528293B0A2020202020202020202020206D61696E54657874617265612E706172656E7428292E66696E6428272E75706C6F61642E696E6C696E652D62';
wwv_flow_api.g_varchar2_table(348) := '7574746F6E27292E73686F7728293B0A2020202020202020202020206D61696E54657874617265612E626C757228293B0A20202020202020207D2C0A0A2020202020202020696E63726561736554657874617265614865696768743A2066756E6374696F';
wwv_flow_api.g_varchar2_table(349) := '6E28657629207B0A202020202020202020202020766172207465787461726561203D20242865762E63757272656E74546172676574293B0A202020202020202020202020746869732E61646A757374546578746172656148656967687428746578746172';
wwv_flow_api.g_varchar2_table(350) := '65612C2074727565293B0A20202020202020207D2C0A0A20202020202020207465787461726561436F6E74656E744368616E6765643A2066756E6374696F6E28657629207B0A202020202020202020202020766172207465787461726561203D20242865';
wwv_flow_api.g_varchar2_table(351) := '762E63757272656E74546172676574293B0A0A2020202020202020202020202F2F2055706461746520706172656E74206964206966207265706C792D746F20746167207761732072656D6F7665640A202020202020202020202020696628217465787461';
wwv_flow_api.g_varchar2_table(352) := '7265612E66696E6428272E7265706C792D746F2E74616727292E6C656E67746829207B0A2020202020202020202020202020202076617220636F6D6D656E744964203D2074657874617265612E617474722827646174612D636F6D6D656E7427293B0A0A';
wwv_flow_api.g_varchar2_table(353) := '202020202020202020202020202020202F2F20436173653A2065646974696E6720636F6D6D656E740A20202020202020202020202020202020696628636F6D6D656E74496429207B0A202020202020202020202020202020202020202076617220706172';
wwv_flow_api.g_varchar2_table(354) := '656E74436F6D6D656E7473203D2074657874617265612E706172656E747328276C692E636F6D6D656E7427293B0A2020202020202020202020202020202020202020696628706172656E74436F6D6D656E74732E6C656E677468203E203129207B0A2020';
wwv_flow_api.g_varchar2_table(355) := '2020202020202020202020202020202020202020202076617220706172656E744964203D20706172656E74436F6D6D656E74732E6C61737428292E646174612827696427293B0A2020202020202020202020202020202020202020202020207465787461';
wwv_flow_api.g_varchar2_table(356) := '7265612E617474722827646174612D706172656E74272C20706172656E744964293B0A20202020202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F20436173653A206E657720636F6D6D656E740A2020202020';
wwv_flow_api.g_varchar2_table(357) := '20202020202020202020207D20656C7365207B0A202020202020202020202020202020202020202076617220706172656E744964203D2074657874617265612E706172656E747328276C692E636F6D6D656E7427292E6C61737428292E64617461282769';
wwv_flow_api.g_varchar2_table(358) := '6427293B0A202020202020202020202020202020202020202074657874617265612E617474722827646174612D706172656E74272C20706172656E744964293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020';
wwv_flow_api.g_varchar2_table(359) := '202020202020202020202F2F204D6F766520636C6F736520627574746F6E206966207363726F6C6C6261722069732076697369626C650A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D2074657874617265612E7061';
wwv_flow_api.g_varchar2_table(360) := '72656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B0A20202020202020202020202069662874657874617265615B305D2E7363726F6C6C486569676874203E2074657874617265612E6F757465724865696768742829';
wwv_flow_api.g_varchar2_table(361) := '29207B0A20202020202020202020202020202020636F6D6D656E74696E674669656C642E616464436C6173732827636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C6527293B0A2020202020202020202020207D20656C7365207B0A2020';
wwv_flow_api.g_varchar2_table(362) := '2020202020202020202020202020636F6D6D656E74696E674669656C642E72656D6F7665436C6173732827636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C6527293B0A2020202020202020202020207D0A0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(363) := '202F2F20436865636B206966207361766520627574746F6E206E6565647320746F20626520656E61626C65640A202020202020202020202020746869732E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64293B0A202020';
wwv_flow_api.g_varchar2_table(364) := '20202020207D2C0A0A2020202020202020746F67676C6553617665427574746F6E3A2066756E6374696F6E28636F6D6D656E74696E674669656C6429207B0A202020202020202020202020766172207465787461726561203D20636F6D6D656E74696E67';
wwv_flow_api.g_varchar2_table(365) := '4669656C642E66696E6428272E746578746172656127293B0A2020202020202020202020207661722073617665427574746F6E203D2074657874617265612E7369626C696E677328272E636F6E74726F6C2D726F7727292E66696E6428272E7361766527';
wwv_flow_api.g_varchar2_table(366) := '293B0A0A20202020202020202020202076617220636F6E74656E74203D20746869732E6765745465787461726561436F6E74656E742874657874617265612C2074727565293B0A202020202020202020202020766172206174746163686D656E7473203D';
wwv_flow_api.g_varchar2_table(367) := '20746869732E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C6428636F6D6D656E74696E674669656C64293B0A20202020202020202020202076617220656E61626C65643B0A0A2020202020202020202020202F2F2043';
wwv_flow_api.g_varchar2_table(368) := '6173653A206578697374696E6720636F6D6D656E740A202020202020202020202020696628636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B74657874617265612E617474722827646174612D636F6D6D656E7427295D';
wwv_flow_api.g_varchar2_table(369) := '29207B0A0A202020202020202020202020202020202F2F20436173653A20706172656E74206368616E6765640A2020202020202020202020202020202076617220636F6E74656E744368616E676564203D20636F6E74656E7420213D20636F6D6D656E74';
wwv_flow_api.g_varchar2_table(370) := '4D6F64656C2E636F6E74656E743B0A2020202020202020202020202020202076617220706172656E7446726F6D4D6F64656C3B0A20202020202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A202020202020';
wwv_flow_api.g_varchar2_table(371) := '2020202020202020202020202020706172656E7446726F6D4D6F64656C203D20636F6D6D656E744D6F64656C2E706172656E742E746F537472696E6728293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F';
wwv_flow_api.g_varchar2_table(372) := '2F20436173653A20706172656E74206368616E6765640A2020202020202020202020202020202076617220706172656E744368616E676564203D2074657874617265612E617474722827646174612D706172656E74272920213D20706172656E7446726F';
wwv_flow_api.g_varchar2_table(373) := '6D4D6F64656C3B0A0A202020202020202020202020202020202F2F20436173653A206174746163686D656E7473206368616E6765640A20202020202020202020202020202020766172206174746163686D656E74734368616E676564203D2066616C7365';
wwv_flow_api.g_varchar2_table(374) := '3B0A20202020202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A20202020202020202020202020202020202020207661722073617665644174746163686D656E74496473203D20';
wwv_flow_api.g_varchar2_table(375) := '636F6D6D656E744D6F64656C2E6174746163686D656E74732E6D61702866756E6374696F6E286174746163686D656E74297B72657475726E206174746163686D656E742E69647D293B0A2020202020202020202020202020202020202020766172206375';
wwv_flow_api.g_varchar2_table(376) := '7272656E744174746163686D656E74496473203D206174746163686D656E74732E6D61702866756E6374696F6E286174746163686D656E74297B72657475726E206174746163686D656E742E69647D293B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(377) := '20206174746163686D656E74734368616E676564203D2021746869732E617265417272617973457175616C2873617665644174746163686D656E744964732C2063757272656E744174746163686D656E74496473293B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(378) := '2020207D0A0A20202020202020202020202020202020656E61626C6564203D20636F6E74656E744368616E676564207C7C20706172656E744368616E676564207C7C206174746163686D656E74734368616E6765643B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(379) := '2F2F20436173653A206E657720636F6D6D656E740A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020656E61626C6564203D20426F6F6C65616E28636F6E74656E742E6C656E67746829207C7C20426F6F6C65';
wwv_flow_api.g_varchar2_table(380) := '616E286174746163686D656E74732E6C656E677468293B0A2020202020202020202020207D0A0A20202020202020202020202073617665427574746F6E2E746F67676C65436C6173732827656E61626C6564272C20656E61626C6564293B0A2020202020';
wwv_flow_api.g_varchar2_table(381) := '2020207D2C0A0A202020202020202072656D6F7665436F6D6D656E74696E674669656C643A2066756E6374696F6E28657629207B0A20202020202020202020202076617220636C6F7365427574746F6E203D20242865762E63757272656E745461726765';
wwv_flow_api.g_varchar2_table(382) := '74293B0A0A2020202020202020202020202F2F2052656D6F7665206564697420636C6173732066726F6D20636F6D6D656E742069662075736572207761732065646974696E672074686520636F6D6D656E740A2020202020202020202020207661722074';
wwv_flow_api.g_varchar2_table(383) := '65787461726561203D20636C6F7365427574746F6E2E7369626C696E677328272E746578746172656127293B0A20202020202020202020202069662874657874617265612E617474722827646174612D636F6D6D656E74272929207B0A20202020202020';
wwv_flow_api.g_varchar2_table(384) := '202020202020202020636C6F7365427574746F6E2E706172656E747328276C692E636F6D6D656E7427292E666972737428292E72656D6F7665436C61737328276564697427293B0A2020202020202020202020207D0A0A2020202020202020202020202F';
wwv_flow_api.g_varchar2_table(385) := '2F2052656D6F766520746865206669656C640A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D20636C6F7365427574746F6E2E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428';
wwv_flow_api.g_varchar2_table(386) := '293B0A202020202020202020202020636F6D6D656E74696E674669656C642E72656D6F766528293B0A20202020202020207D2C0A0A2020202020202020706F7374436F6D6D656E743A2066756E6374696F6E28657629207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(387) := '207661722073656C66203D20746869733B0A2020202020202020202020207661722073656E64427574746F6E203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D656E74696E674669656C6420';
wwv_flow_api.g_varchar2_table(388) := '3D2073656E64427574746F6E2E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B0A0A2020202020202020202020202F2F2053657420627574746F6E20737461746520746F206C6F6164696E670A2020202020';
wwv_flow_api.g_varchar2_table(389) := '20202020202020746869732E736574427574746F6E53746174652873656E64427574746F6E2C2066616C73652C2074727565293B0A0A2020202020202020202020202F2F2043726561746520636F6D6D656E74204A534F4E0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(390) := '2076617220636F6D6D656E744A534F4E203D20746869732E637265617465436F6D6D656E744A534F4E28636F6D6D656E74696E674669656C64293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E670A2020202020202020';
wwv_flow_api.g_varchar2_table(391) := '20202020636F6D6D656E744A534F4E203D20746869732E6170706C7945787465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E28636F6D6D65';
wwv_flow_api.g_varchar2_table(392) := '6E744A534F4E29207B0A2020202020202020202020202020202073656C662E637265617465436F6D6D656E7428636F6D6D656E744A534F4E293B0A20202020202020202020202020202020636F6D6D656E74696E674669656C642E66696E6428272E636C';
wwv_flow_api.g_varchar2_table(393) := '6F736527292E747269676765722827636C69636B27293B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652873';
wwv_flow_api.g_varchar2_table(394) := '656E64427574746F6E2C2066616C73652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F2052';
wwv_flow_api.g_varchar2_table(395) := '6573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652873656E64427574746F6E2C20747275652C2066616C7365293B0A2020202020202020202020207D3B0A0A20202020';
wwv_flow_api.g_varchar2_table(396) := '2020202020202020746869732E6F7074696F6E732E706F7374436F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E743A206675';
wwv_flow_api.g_varchar2_table(397) := '6E6374696F6E28636F6D6D656E744A534F4E29207B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E637265617465436F6D6D656E744D6F64656C28636F6D6D656E744A534F4E293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(398) := '202020746869732E616464436F6D6D656E74546F446174614D6F64656C28636F6D6D656E744D6F64656C293B0A0A2020202020202020202020202F2F2041646420636F6D6D656E7420656C656D656E740A20202020202020202020202076617220636F6D';
wwv_flow_api.g_varchar2_table(399) := '6D656E744C697374203D20746869732E24656C2E66696E64282723636F6D6D656E742D6C69737427293B0A2020202020202020202020207661722070726570656E64436F6D6D656E74203D20746869732E63757272656E74536F72744B6579203D3D2027';
wwv_flow_api.g_varchar2_table(400) := '6E6577657374273B0A202020202020202020202020746869732E616464436F6D6D656E7428636F6D6D656E744D6F64656C2C20636F6D6D656E744C6973742C2070726570656E64436F6D6D656E74293B0A0A202020202020202020202020696628746869';
wwv_flow_api.g_varchar2_table(401) := '732E63757272656E74536F72744B6579203D3D20276174746163686D656E74732720262620636F6D6D656E744D6F64656C2E6861734174746163686D656E7473282929207B0A20202020202020202020202020202020746869732E616464417474616368';
wwv_flow_api.g_varchar2_table(402) := '6D656E7428636F6D6D656E744D6F64656C293B0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020707574436F6D6D656E743A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C';
wwv_flow_api.g_varchar2_table(403) := '66203D20746869733B0A2020202020202020202020207661722073617665427574746F6E203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D20736176654275';
wwv_flow_api.g_varchar2_table(404) := '74746F6E2E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B0A202020202020202020202020766172207465787461726561203D20636F6D6D656E74696E674669656C642E66696E6428272E74657874617265';
wwv_flow_api.g_varchar2_table(405) := '6127293B0A0A2020202020202020202020202F2F2053657420627574746F6E20737461746520746F206C6F6164696E670A202020202020202020202020746869732E736574427574746F6E53746174652873617665427574746F6E2C2066616C73652C20';
wwv_flow_api.g_varchar2_table(406) := '74727565293B0A0A2020202020202020202020202F2F20557365206120636C6F6E65206F6620746865206578697374696E67206D6F64656C20616E642075706461746520746865206D6F64656C2061667465722073756363657366756C6C207570646174';
wwv_flow_api.g_varchar2_table(407) := '650A20202020202020202020202076617220636F6D6D656E744A534F4E203D2020242E657874656E64287B7D2C20746869732E636F6D6D656E7473427949645B74657874617265612E617474722827646174612D636F6D6D656E7427295D293B0A202020';
wwv_flow_api.g_varchar2_table(408) := '202020202020202020242E657874656E6428636F6D6D656E744A534F4E2C207B0A20202020202020202020202020202020706172656E743A2074657874617265612E617474722827646174612D706172656E742729207C7C206E756C6C2C0A2020202020';
wwv_flow_api.g_varchar2_table(409) := '2020202020202020202020636F6E74656E743A20746869732E6765745465787461726561436F6E74656E74287465787461726561292C0A2020202020202020202020202020202070696E67733A20746869732E67657450696E6773287465787461726561';
wwv_flow_api.g_varchar2_table(410) := '292C0A202020202020202020202020202020206D6F6469666965643A206E6577204461746528292E67657454696D6528292C0A202020202020202020202020202020206174746163686D656E74733A20746869732E6765744174746163686D656E747346';
wwv_flow_api.g_varchar2_table(411) := '726F6D436F6D6D656E74696E674669656C6428636F6D6D656E74696E674669656C64290A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E670A202020202020202020202020636F6D6D';
wwv_flow_api.g_varchar2_table(412) := '656E744A534F4E203D20746869732E6170706C7945787465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E28636F6D6D656E744A534F4E2920';
wwv_flow_api.g_varchar2_table(413) := '7B0A202020202020202020202020202020202F2F20546865206F757465726D6F737420706172656E742063616E206E6F74206265206368616E6765642062792065646974696E672074686520636F6D6D656E7420736F20746865206368696C6473206172';
wwv_flow_api.g_varchar2_table(414) := '7261790A202020202020202020202020202020202F2F206F6620706172656E7420646F6573206E6F74207265717569726520616E207570646174650A0A2020202020202020202020202020202076617220636F6D6D656E744D6F64656C203D2073656C66';
wwv_flow_api.g_varchar2_table(415) := '2E637265617465436F6D6D656E744D6F64656C28636F6D6D656E744A534F4E293B0A0A202020202020202020202020202020202F2F2044656C657465206368696C64732061727261792066726F6D206E657720636F6D6D656E74206D6F64656C2073696E';
wwv_flow_api.g_varchar2_table(416) := '636520697420646F65736E2774206E65656420616E207570646174650A2020202020202020202020202020202064656C65746520636F6D6D656E744D6F64656C5B276368696C6473275D3B0A2020202020202020202020202020202073656C662E757064';
wwv_flow_api.g_varchar2_table(417) := '617465436F6D6D656E744D6F64656C28636F6D6D656E744D6F64656C293B0A0A202020202020202020202020202020202F2F20436C6F7365207468652065646974696E67206669656C640A20202020202020202020202020202020636F6D6D656E74696E';
wwv_flow_api.g_varchar2_table(418) := '674669656C642E66696E6428272E636C6F736527292E747269676765722827636C69636B27293B0A0A202020202020202020202020202020202F2F2052652D72656E6465722074686520636F6D6D656E740A202020202020202020202020202020207365';
wwv_flow_api.g_varchar2_table(419) := '6C662E726552656E646572436F6D6D656E7428636F6D6D656E744D6F64656C2E6964293B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574';
wwv_flow_api.g_varchar2_table(420) := '427574746F6E53746174652873617665427574746F6E2C2066616C73652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(421) := '2020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652873617665427574746F6E2C20747275652C2066616C7365293B0A20202020202020';
wwv_flow_api.g_varchar2_table(422) := '20202020207D3B0A0A202020202020202020202020746869732E6F7074696F6E732E707574436F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A202020202020202064656C6574';
wwv_flow_api.g_varchar2_table(423) := '65436F6D6D656E743A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A2020202020202020202020207661722064656C657465427574746F6E203D20242865762E63757272656E74546172';
wwv_flow_api.g_varchar2_table(424) := '676574293B0A20202020202020202020202076617220636F6D6D656E74456C203D2064656C657465427574746F6E2E706172656E747328272E636F6D6D656E7427292E666972737428293B0A20202020202020202020202076617220636F6D6D656E744A';
wwv_flow_api.g_varchar2_table(425) := '534F4E203D2020242E657874656E64287B7D2C20746869732E636F6D6D656E7473427949645B636F6D6D656E74456C2E617474722827646174612D696427295D293B0A20202020202020202020202076617220636F6D6D656E744964203D20636F6D6D65';
wwv_flow_api.g_varchar2_table(426) := '6E744A534F4E2E69643B0A20202020202020202020202076617220706172656E744964203D20636F6D6D656E744A534F4E2E706172656E743B0A0A2020202020202020202020202F2F2053657420627574746F6E20737461746520746F206C6F6164696E';
wwv_flow_api.g_varchar2_table(427) := '670A202020202020202020202020746869732E736574427574746F6E53746174652864656C657465427574746F6E2C2066616C73652C2074727565293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E670A202020202020';
wwv_flow_api.g_varchar2_table(428) := '202020202020636F6D6D656E744A534F4E203D20746869732E6170706C7945787465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E2829207B';
wwv_flow_api.g_varchar2_table(429) := '0A2020202020202020202020202020202073656C662E72656D6F7665436F6D6D656E7428636F6D6D656E744964293B0A20202020202020202020202020202020696628706172656E744964292073656C662E726552656E646572436F6D6D656E74416374';
wwv_flow_api.g_varchar2_table(430) := '696F6E42617228706172656E744964293B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652864656C65746542';
wwv_flow_api.g_varchar2_table(431) := '7574746F6E2C2066616C73652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F205265736574';
wwv_flow_api.g_varchar2_table(432) := '20627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652864656C657465427574746F6E2C20747275652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020';
wwv_flow_api.g_varchar2_table(433) := '202020202020746869732E6F7074696F6E732E64656C657465436F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A202020202020202068617368746167436C69636B65643A2066';
wwv_flow_api.g_varchar2_table(434) := '756E6374696F6E28657629207B0A20202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A2020202020202020202020207661722076616C7565203D20656C2E617474722827646174612D76616C756527';
wwv_flow_api.g_varchar2_table(435) := '293B0A202020202020202020202020746869732E6F7074696F6E732E68617368746167436C69636B65642876616C7565293B0A20202020202020207D2C0A0A202020202020202070696E67436C69636B65643A2066756E6374696F6E28657629207B0A20';
wwv_flow_api.g_varchar2_table(436) := '202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A2020202020202020202020207661722076616C7565203D20656C2E617474722827646174612D76616C756527293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(437) := '746869732E6F7074696F6E732E70696E67436C69636B65642876616C7565293B0A20202020202020207D2C0A0A202020202020202066696C65496E7075744368616E6765643A2066756E6374696F6E2865762C2066696C657329207B0A20202020202020';
wwv_flow_api.g_varchar2_table(438) := '20202020207661722066696C6573203D2065762E63757272656E745461726765742E66696C65733B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D20242865762E63757272656E74546172676574292E706172656E';
wwv_flow_api.g_varchar2_table(439) := '747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B0A202020202020202020202020746869732E707265536176654174746163686D656E74732866696C65732C20636F6D6D656E74696E674669656C64293B0A202020202020';
wwv_flow_api.g_varchar2_table(440) := '20207D2C0A0A20202020202020207570766F7465436F6D6D656E743A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220636F6D6D656E74456C203D';
wwv_flow_api.g_varchar2_table(441) := '20242865762E63757272656E74546172676574292E706172656E747328276C692E636F6D6D656E7427292E666972737428293B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20636F6D6D656E74456C2E6461746128292E';
wwv_flow_api.g_varchar2_table(442) := '6D6F64656C3B0A0A2020202020202020202020202F2F20436865636B20776865746865722075736572207570766F7465642074686520636F6D6D656E74206F72207265766F6B656420746865207570766F74650A20202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(443) := '70726576696F75735570766F7465436F756E74203D20636F6D6D656E744D6F64656C2E7570766F7465436F756E743B0A202020202020202020202020766172206E65775570766F7465436F756E743B0A202020202020202020202020696628636F6D6D65';
wwv_flow_api.g_varchar2_table(444) := '6E744D6F64656C2E757365724861735570766F74656429207B0A202020202020202020202020202020206E65775570766F7465436F756E74203D2070726576696F75735570766F7465436F756E74202D20313B0A2020202020202020202020207D20656C';
wwv_flow_api.g_varchar2_table(445) := '7365207B0A202020202020202020202020202020206E65775570766F7465436F756E74203D2070726576696F75735570766F7465436F756E74202B20313B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2053686F77206368';
wwv_flow_api.g_varchar2_table(446) := '616E67657320696D6D6564696174656C790A202020202020202020202020636F6D6D656E744D6F64656C2E757365724861735570766F746564203D2021636F6D6D656E744D6F64656C2E757365724861735570766F7465643B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(447) := '2020636F6D6D656E744D6F64656C2E7570766F7465436F756E74203D206E65775570766F7465436F756E743B0A202020202020202020202020746869732E726552656E6465725570766F74657328636F6D6D656E744D6F64656C2E6964293B0A0A202020';
wwv_flow_api.g_varchar2_table(448) := '2020202020202020202F2F2052657665727365206D617070696E670A20202020202020202020202076617220636F6D6D656E744A534F4E203D20242E657874656E64287B7D2C20636F6D6D656E744D6F64656C293B0A202020202020202020202020636F';
wwv_flow_api.g_varchar2_table(449) := '6D6D656E744A534F4E203D20746869732E6170706C7945787465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E28636F6D6D656E744A534F4E';
wwv_flow_api.g_varchar2_table(450) := '29207B0A2020202020202020202020202020202076617220636F6D6D656E744D6F64656C203D2073656C662E637265617465436F6D6D656E744D6F64656C28636F6D6D656E744A534F4E293B0A2020202020202020202020202020202073656C662E7570';
wwv_flow_api.g_varchar2_table(451) := '64617465436F6D6D656E744D6F64656C28636F6D6D656E744D6F64656C293B0A2020202020202020202020202020202073656C662E726552656E6465725570766F74657328636F6D6D656E744D6F64656C2E6964293B0A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(452) := '3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F20526576657274206368616E6765730A20202020202020202020202020202020636F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(453) := '64656C2E757365724861735570766F746564203D2021636F6D6D656E744D6F64656C2E757365724861735570766F7465643B0A20202020202020202020202020202020636F6D6D656E744D6F64656C2E7570766F7465436F756E74203D2070726576696F';
wwv_flow_api.g_varchar2_table(454) := '75735570766F7465436F756E743B0A2020202020202020202020202020202073656C662E726552656E6465725570766F74657328636F6D6D656E744D6F64656C2E6964293B0A2020202020202020202020207D3B0A0A2020202020202020202020207468';
wwv_flow_api.g_varchar2_table(455) := '69732E6F7074696F6E732E7570766F7465436F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A2020202020202020746F67676C655265706C6965733A2066756E6374696F6E2865';
wwv_flow_api.g_varchar2_table(456) := '7629207B0A20202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A202020202020202020202020656C2E7369626C696E677328272E746F67676C61626C652D7265706C7927292E746F67676C65436C61';
wwv_flow_api.g_varchar2_table(457) := '7373282776697369626C6527293B0A202020202020202020202020746869732E736574546F67676C65416C6C427574746F6E5465787428656C2C2074727565293B0A20202020202020207D2C0A0A20202020202020207265706C79427574746F6E436C69';
wwv_flow_api.g_varchar2_table(458) := '636B65643A2066756E6374696F6E28657629207B202F2F4D4F444946494544205249434841524442414C444F47490A202020202020202020202020766172207265706C79427574746F6E203D20242865762E63757272656E74546172676574293B0A2020';
wwv_flow_api.g_varchar2_table(459) := '20202020202020202020766172206F757465726D6F7374506172656E74203D207265706C79427574746F6E2E706172656E747328272E636F6D6D656E7427292E666972737428292E6368696C6472656E28292E666972737428293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(460) := '2020202076617220706172656E744964203D207265706C79427574746F6E2E706172656E747328272E636F6D6D656E7427292E666972737428292E6461746128292E69643B0A0A2020202020202020202020202F2F2052656D6F7665206578697374696E';
wwv_flow_api.g_varchar2_table(461) := '67206669656C640A202020202020202020202020766172207265706C794669656C64203D2024282723636F6D6D656E742D6C69737427292E66696E6428272E636F6D6D656E74696E672D6669656C6427293B0A2020202020202020202020206966287265';
wwv_flow_api.g_varchar2_table(462) := '706C794669656C642E6C656E67746829207265706C794669656C642E72656D6F766528293B0A2020202020202020202020207661722070726576696F7573506172656E744964203D207265706C794669656C642E66696E6428272E746578746172656127';
wwv_flow_api.g_varchar2_table(463) := '292E617474722827646174612D706172656E7427293B0A0A2020202020202020202020202F2F2043726561746520746865207265706C79206669656C642028646F206E6F742072652D637265617465290A20202020202020202020202069662870726576';
wwv_flow_api.g_varchar2_table(464) := '696F7573506172656E74496420213D20706172656E74496429207B0A202020202020202020202020202020207265706C794669656C64203D20746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E7428706172656E74496429';
wwv_flow_api.g_varchar2_table(465) := '3B0A202020202020202020202020202020206F757465726D6F7374506172656E742E66696E6428272E7772617070657227292E666972737428292E6166746572287265706C794669656C64293B0A202020202020202020202020202020202F2F204D6F76';
wwv_flow_api.g_varchar2_table(466) := '6520637572736F7220746F20656E640A20202020202020202020202020202020766172207465787461726561203D207265706C794669656C642E66696E6428272E746578746172656127293B0A20202020202020202020202020202020746869732E6D6F';
wwv_flow_api.g_varchar2_table(467) := '7665437572736F72546F456E64287465787461726561293B0A0A202020202020202020202020202020202F2F20456E7375726520656C656D656E742073746179732076697369626C650A20202020202020202020202020202020746869732E656E737572';
wwv_flow_api.g_varchar2_table(468) := '65456C656D656E74537461797356697369626C65287265706C794669656C64293B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202065646974427574746F6E436C69636B65643A2066756E6374696F6E2865762920';
wwv_flow_api.g_varchar2_table(469) := '7B0A2020202020202020202020207661722065646974427574746F6E203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D656E74456C203D2065646974427574746F6E2E706172656E74732827';
wwv_flow_api.g_varchar2_table(470) := '6C692E636F6D6D656E7427292E666972737428293B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20636F6D6D656E74456C2E6461746128292E6D6F64656C3B0A202020202020202020202020636F6D6D656E74456C2E61';
wwv_flow_api.g_varchar2_table(471) := '6464436C61737328276564697427293B0A0A2020202020202020202020202F2F20437265617465207468652065646974696E67206669656C640A20202020202020202020202076617220656469744669656C64203D20746869732E637265617465436F6D';
wwv_flow_api.g_varchar2_table(472) := '6D656E74696E674669656C64456C656D656E7428636F6D6D656E744D6F64656C2E706172656E742C20636F6D6D656E744D6F64656C2E6964293B0A202020202020202020202020636F6D6D656E74456C2E66696E6428272E636F6D6D656E742D77726170';
wwv_flow_api.g_varchar2_table(473) := '70657227292E666972737428292E617070656E6428656469744669656C64293B0A0A2020202020202020202020202F2F20417070656E64206F726967696E616C20636F6E74656E740A202020202020202020202020766172207465787461726561203D20';
wwv_flow_api.g_varchar2_table(474) := '656469744669656C642E66696E6428272E746578746172656127293B0A20202020202020202020202074657874617265612E617474722827646174612D636F6D6D656E74272C20636F6D6D656E744D6F64656C2E6964293B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(475) := '20202F2F204573636170696E672048544D4C0A20202020202020202020202074657874617265612E617070656E6428746869732E676574466F726D6174746564436F6D6D656E74436F6E74656E7428636F6D6D656E744D6F64656C2C207472756529293B';
wwv_flow_api.g_varchar2_table(476) := '0A0A2020202020202020202020202F2F204D6F766520637572736F7220746F20656E640A202020202020202020202020746869732E6D6F7665437572736F72546F456E64287465787461726561293B0A0A2020202020202020202020202F2F20456E7375';
wwv_flow_api.g_varchar2_table(477) := '726520656C656D656E742073746179732076697369626C650A202020202020202020202020746869732E656E73757265456C656D656E74537461797356697369626C6528656469744669656C64293B0A20202020202020207D2C0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(478) := '73686F7744726F707061626C654F7665726C61793A2066756E6374696F6E28657629207B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(479) := '2020746869732E24656C2E66696E6428272E64726F707061626C652D6F7665726C617927292E6373732827746F70272C20746869732E24656C5B305D2E7363726F6C6C546F70293B0A20202020202020202020202020202020746869732E24656C2E6669';
wwv_flow_api.g_varchar2_table(480) := '6E6428272E64726F707061626C652D6F7665726C617927292E73686F7728293B0A20202020202020202020202020202020746869732E24656C2E616464436C6173732827647261672D6F6E676F696E6727293B0A2020202020202020202020207D0A2020';
wwv_flow_api.g_varchar2_table(481) := '2020202020207D2C0A0A202020202020202068616E646C6544726167456E7465723A2066756E6374696F6E28657629207B0A20202020202020202020202076617220636F756E74203D20242865762E63757272656E74546172676574292E646174612827';
wwv_flow_api.g_varchar2_table(482) := '646E642D636F756E742729207C7C20303B0A202020202020202020202020636F756E742B2B3B0A202020202020202020202020242865762E63757272656E74546172676574292E646174612827646E642D636F756E74272C20636F756E74293B0A202020';
wwv_flow_api.g_varchar2_table(483) := '202020202020202020242865762E63757272656E74546172676574292E616464436C6173732827647261672D6F76657227293B0A20202020202020207D2C0A0A202020202020202068616E646C65447261674C656176653A2066756E6374696F6E286576';
wwv_flow_api.g_varchar2_table(484) := '2C2063616C6C6261636B29207B0A20202020202020202020202076617220636F756E74203D20242865762E63757272656E74546172676574292E646174612827646E642D636F756E7427293B0A202020202020202020202020636F756E742D2D3B0A2020';
wwv_flow_api.g_varchar2_table(485) := '20202020202020202020242865762E63757272656E74546172676574292E646174612827646E642D636F756E74272C20636F756E74293B0A0A202020202020202020202020696628636F756E74203D3D203029207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(486) := '2020242865762E63757272656E74546172676574292E72656D6F7665436C6173732827647261672D6F76657227293B0A2020202020202020202020202020202069662863616C6C6261636B292063616C6C6261636B28293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(487) := '207D0A20202020202020207D2C0A0A202020202020202068616E646C65447261674C65617665466F724F7665726C61793A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020';
wwv_flow_api.g_varchar2_table(488) := '202020202020746869732E68616E646C65447261674C656176652865762C2066756E6374696F6E2829207B0A2020202020202020202020202020202073656C662E6869646544726F707061626C654F7665726C617928293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(489) := '207D293B0A20202020202020207D2C0A0A202020202020202068616E646C65447261674C65617665466F7244726F707061626C653A2066756E6374696F6E28657629207B0A202020202020202020202020746869732E68616E646C65447261674C656176';
wwv_flow_api.g_varchar2_table(490) := '65286576293B0A20202020202020207D2C0A0A202020202020202068616E646C65447261674F766572466F724F7665726C61793A2066756E6374696F6E28657629207B0A20202020202020202020202065762E73746F7050726F7061676174696F6E2829';
wwv_flow_api.g_varchar2_table(491) := '3B0A20202020202020202020202065762E70726576656E7444656661756C7428293B0A20202020202020202020202065762E6F726967696E616C4576656E742E646174615472616E736665722E64726F70456666656374203D2027636F7079273B0A2020';
wwv_flow_api.g_varchar2_table(492) := '2020202020207D2C0A0A20202020202020206869646544726F707061626C654F7665726C61793A2066756E6374696F6E2829207B0A202020202020202020202020746869732E24656C2E66696E6428272E64726F707061626C652D6F7665726C61792729';
wwv_flow_api.g_varchar2_table(493) := '2E6869646528293B0A202020202020202020202020746869732E24656C2E72656D6F7665436C6173732827647261672D6F6E676F696E6727293B0A20202020202020207D2C0A0A202020202020202068616E646C6544726F703A2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(494) := '657629207B0A20202020202020202020202065762E70726576656E7444656661756C7428293B0A0A2020202020202020202020202F2F20526573657420444E4420636F756E74730A202020202020202020202020242865762E746172676574292E747269';
wwv_flow_api.g_varchar2_table(495) := '676765722827647261676C6561766527293B0A0A2020202020202020202020202F2F204869646520746865206F7665726C617920616E642075706C6F6164207468652066696C65730A202020202020202020202020746869732E6869646544726F707061';
wwv_flow_api.g_varchar2_table(496) := '626C654F7665726C617928293B0A202020202020202020202020746869732E707265536176654174746163686D656E74732865762E6F726967696E616C4576656E742E646174615472616E736665722E66696C6573293B0A20202020202020207D2C0A0A';
wwv_flow_api.g_varchar2_table(497) := '202020202020202073746F7050726F7061676174696F6E3A2066756E6374696F6E28657629207B0A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0A20202020202020207D2C0A0A0A20202020202020202F2F204854';
wwv_flow_api.g_varchar2_table(498) := '4D4C20656C656D656E74730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D0A0A202020202020202063726561746548544D4C3A2066756E6374696F6E2829207B0A2020202020202020202020207661722073656C66203D20746869733B0A';
wwv_flow_api.g_varchar2_table(499) := '0A2020202020202020202020202F2F20436F6D6D656E74696E67206669656C640A202020202020202020202020766172206D61696E436F6D6D656E74696E674669656C64203D20746869732E6372656174654D61696E436F6D6D656E74696E674669656C';
wwv_flow_api.g_varchar2_table(500) := '64456C656D656E7428293B0A202020202020202020202020746869732E24656C2E617070656E64286D61696E436F6D6D656E74696E674669656C64293B0A0A2020202020202020202020202F2F204869646520636F6E74726F6C20726F7720616E642063';
wwv_flow_api.g_varchar2_table(501) := '6C6F736520627574746F6E0A202020202020202020202020766172206D61696E436F6E74726F6C526F77203D206D61696E436F6D6D656E74696E674669656C642E66696E6428272E636F6E74726F6C2D726F7727293B0A2020202020202020202020206D';
wwv_flow_api.g_varchar2_table(502) := '61696E436F6E74726F6C526F772E6869646528293B0A2020202020202020202020206D61696E436F6D6D656E74696E674669656C642E66696E6428272E636C6F736527292E6869646528293B0A0A2020202020202020202020202F2F204E617669676174';
wwv_flow_api.g_varchar2_table(503) := '696F6E206261720A20202020202020202020202069662028746869732E6F7074696F6E732E656E61626C654E617669676174696F6E29207B0A20202020202020202020202020202020746869732E24656C2E617070656E6428746869732E637265617465';
wwv_flow_api.g_varchar2_table(504) := '4E617669676174696F6E456C656D656E742829293B0A20202020202020202020202020202020746869732E73686F77416374697665536F727428293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F204C6F6164696E672073';
wwv_flow_api.g_varchar2_table(505) := '70696E6E65720A202020202020202020202020766172207370696E6E6572203D20746869732E6372656174655370696E6E657228293B0A202020202020202020202020746869732E24656C2E617070656E64287370696E6E6572293B0A0A202020202020';
wwv_flow_api.g_varchar2_table(506) := '2020202020202F2F20436F6D6D656E747320636F6E7461696E65720A20202020202020202020202076617220636F6D6D656E7473436F6E7461696E6572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373';
wwv_flow_api.g_varchar2_table(507) := '273A2027646174612D636F6E7461696E6572272C0A2020202020202020202020202020202027646174612D636F6E7461696E6572273A2027636F6D6D656E7473270A2020202020202020202020207D293B0A202020202020202020202020746869732E24';
wwv_flow_api.g_varchar2_table(508) := '656C2E617070656E6428636F6D6D656E7473436F6E7461696E6572293B0A0A2020202020202020202020202F2F20224E6F20636F6D6D656E74732220706C616365686F6C6465720A202020202020202020202020766172206E6F436F6D6D656E7473203D';
wwv_flow_api.g_varchar2_table(509) := '202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E6F2D636F6D6D656E7473206E6F2D64617461272C0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E7465';
wwv_flow_api.g_varchar2_table(510) := '7874466F726D617474657228746869732E6F7074696F6E732E6E6F436F6D6D656E747354657874290A2020202020202020202020207D293B0A202020202020202020202020766172206E6F436F6D6D656E747349636F6E203D202428273C692F3E272C20';
wwv_flow_api.g_varchar2_table(511) := '7B0A2020202020202020202020202020202027636C617373273A202766612066612D636F6D6D656E74732066612D3278270A2020202020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E6E6F436F6D6D';
wwv_flow_api.g_varchar2_table(512) := '656E747349636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020206E6F436F6D6D656E747349636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E6E6F';
wwv_flow_api.g_varchar2_table(513) := '436F6D6D656E747349636F6E55524C2B27222927293B0A202020202020202020202020202020206E6F436F6D6D656E747349636F6E2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A2020202020202020202020206E';
wwv_flow_api.g_varchar2_table(514) := '6F436F6D6D656E74732E70726570656E64282428273C62722F3E2729292E70726570656E64286E6F436F6D6D656E747349636F6E293B0A202020202020202020202020636F6D6D656E7473436F6E7461696E65722E617070656E64286E6F436F6D6D656E';
wwv_flow_api.g_varchar2_table(515) := '7473293B0A0A2020202020202020202020202F2F204174746163686D656E74730A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A0A202020202020202020202020202020202F';
wwv_flow_api.g_varchar2_table(516) := '2F204174746163686D656E747320636F6E7461696E65720A20202020202020202020202020202020766172206174746163686D656E7473436F6E7461696E6572203D202428273C6469762F3E272C207B0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(517) := '2027636C617373273A2027646174612D636F6E7461696E6572272C0A202020202020202020202020202020202020202027646174612D636F6E7461696E6572273A20276174746163686D656E7473270A202020202020202020202020202020207D293B0A';
wwv_flow_api.g_varchar2_table(518) := '20202020202020202020202020202020746869732E24656C2E617070656E64286174746163686D656E7473436F6E7461696E6572293B0A0A202020202020202020202020202020202F2F20224E6F206174746163686D656E74732220706C616365686F6C';
wwv_flow_api.g_varchar2_table(519) := '6465720A20202020202020202020202020202020766172206E6F4174746163686D656E7473203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A20276E6F2D6174746163686D656E7473206E';
wwv_flow_api.g_varchar2_table(520) := '6F2D64617461272C0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E6F4174746163686D656E747354657874290A202020202020';
wwv_flow_api.g_varchar2_table(521) := '202020202020202020207D293B0A20202020202020202020202020202020766172206E6F4174746163686D656E747349636F6E203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202766612066';
wwv_flow_api.g_varchar2_table(522) := '612D7061706572636C69702066612D3278270A202020202020202020202020202020207D293B0A20202020202020202020202020202020696628746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E67746829207B0A20';
wwv_flow_api.g_varchar2_table(523) := '202020202020202020202020202020202020206E6F4174746163686D656E747349636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B';
wwv_flow_api.g_varchar2_table(524) := '27222927293B0A20202020202020202020202020202020202020206E6F4174746163686D656E747349636F6E2E616464436C6173732827696D61676527293B0A202020202020202020202020202020207D0A202020202020202020202020202020206E6F';
wwv_flow_api.g_varchar2_table(525) := '4174746163686D656E74732E70726570656E64282428273C62722F3E2729292E70726570656E64286E6F4174746163686D656E747349636F6E293B0A202020202020202020202020202020206174746163686D656E7473436F6E7461696E65722E617070';
wwv_flow_api.g_varchar2_table(526) := '656E64286E6F4174746163686D656E7473293B0A0A0A202020202020202020202020202020202F2F204472616720262064726F7070696E67206174746163686D656E74730A202020202020202020202020202020207661722064726F707061626C654F76';
wwv_flow_api.g_varchar2_table(527) := '65726C6179203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202764726F707061626C652D6F7665726C6179270A202020202020202020202020202020207D293B0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(528) := '20202020202020207661722064726F707061626C65436F6E7461696E6572203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202764726F707061626C652D636F6E7461696E6572270A2020';
wwv_flow_api.g_varchar2_table(529) := '20202020202020202020202020207D293B0A0A202020202020202020202020202020207661722064726F707061626C65203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202764726F7070';
wwv_flow_api.g_varchar2_table(530) := '61626C65270A202020202020202020202020202020207D293B0A0A202020202020202020202020202020207661722075706C6F616449636F6E203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A';
wwv_flow_api.g_varchar2_table(531) := '202766612066612D7061706572636C69702066612D3478270A202020202020202020202020202020207D293B0A20202020202020202020202020202020696628746869732E6F7074696F6E732E75706C6F616449636F6E55524C2E6C656E67746829207B';
wwv_flow_api.g_varchar2_table(532) := '0A202020202020202020202020202020202020202075706C6F616449636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E75706C6F616449636F6E55524C2B27222927293B0A2020';
wwv_flow_api.g_varchar2_table(533) := '20202020202020202020202020202020202075706C6F616449636F6E2E616464436C6173732827696D61676527293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020207661722064726F704174746163686D656E';
wwv_flow_api.g_varchar2_table(534) := '7454657874203D202428273C6469762F3E272C207B0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6174746163686D656E744472';
wwv_flow_api.g_varchar2_table(535) := '6F7054657874290A202020202020202020202020202020207D293B0A2020202020202020202020202020202064726F707061626C652E617070656E642875706C6F616449636F6E293B0A2020202020202020202020202020202064726F707061626C652E';
wwv_flow_api.g_varchar2_table(536) := '617070656E642864726F704174746163686D656E7454657874293B0A0A2020202020202020202020202020202064726F707061626C654F7665726C61792E68746D6C2864726F707061626C65436F6E7461696E65722E68746D6C2864726F707061626C65';
wwv_flow_api.g_varchar2_table(537) := '29292E6869646528293B0A20202020202020202020202020202020746869732E24656C2E617070656E642864726F707061626C654F7665726C6179293B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202063726561';
wwv_flow_api.g_varchar2_table(538) := '746550726F66696C6550696374757265456C656D656E743A2066756E6374696F6E287372632C2075736572496429207B0A20202020202020202020202069662873726329207B0A20202020202020202020202020207661722070726F66696C6550696374';
wwv_flow_api.g_varchar2_table(539) := '757265203D202428273C6469762F3E27292E637373287B0A202020202020202020202020202020202020276261636B67726F756E642D696D616765273A202775726C2827202B20737263202B202729270A202020202020202020202020202020207D293B';
wwv_flow_api.g_varchar2_table(540) := '0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020207661722070726F66696C6550696374757265203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A20';
wwv_flow_api.g_varchar2_table(541) := '2766612066612D75736572270A202020202020202020202020202020207D293B0A2020202020202020202020207D0A20202020202020202020202070726F66696C65506963747572652E616464436C617373282770726F66696C652D7069637475726527';
wwv_flow_api.g_varchar2_table(542) := '293B0A20202020202020202020202070726F66696C65506963747572652E617474722827646174612D757365722D6964272C20757365724964293B0A202020202020202020202020696628746869732E6F7074696F6E732E726F756E6450726F66696C65';
wwv_flow_api.g_varchar2_table(543) := '5069637475726573292070726F66696C65506963747572652E616464436C6173732827726F756E6427293B0A20202020202020202020202072657475726E2070726F66696C65506963747572653B0A20202020202020207D2C0A0A202020202020202063';
wwv_flow_api.g_varchar2_table(544) := '72656174654D61696E436F6D6D656E74696E674669656C64456C656D656E743A2066756E6374696F6E2829207B0A20202020202020202020202072657475726E20746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E742875';
wwv_flow_api.g_varchar2_table(545) := '6E646566696E65642C20756E646566696E65642C2074727565293B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E74696E674669656C64456C656D656E743A2066756E6374696F6E28706172656E7449642C20657869';
wwv_flow_api.g_varchar2_table(546) := '7374696E67436F6D6D656E7449642C2069734D61696E29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A2020202020202020202020207661722070726F66696C655069637475726555524C3B0A202020202020202020';
wwv_flow_api.g_varchar2_table(547) := '202020766172207573657249643B0A202020202020202020202020766172206174746163686D656E74733B0A0A2020202020202020202020202F2F20436F6D6D656E74696E67206669656C640A20202020202020202020202076617220636F6D6D656E74';
wwv_flow_api.g_varchar2_table(548) := '696E674669656C64203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A2027636F6D6D656E74696E672D6669656C64270A2020202020202020202020207D293B0A202020202020202020202020696628';
wwv_flow_api.g_varchar2_table(549) := '69734D61696E2920636F6D6D656E74696E674669656C642E616464436C61737328276D61696E27293B0A0A2020202020202020202020202F2F20436F6D6D656E7420776173206D6F6469666965642C20757365206578697374696E6720646174610A2020';
wwv_flow_api.g_varchar2_table(550) := '202020202020202020206966286578697374696E67436F6D6D656E74496429207B0A2020202020202020202020202020202070726F66696C655069637475726555524C203D20746869732E636F6D6D656E7473427949645B6578697374696E67436F6D6D';
wwv_flow_api.g_varchar2_table(551) := '656E7449645D2E70726F66696C655069637475726555524C3B0A20202020202020202020202020202020757365724964203D20746869732E636F6D6D656E7473427949645B6578697374696E67436F6D6D656E7449645D2E63726561746F723B0A202020';
wwv_flow_api.g_varchar2_table(552) := '202020202020202020202020206174746163686D656E7473203D20746869732E636F6D6D656E7473427949645B6578697374696E67436F6D6D656E7449645D2E6174746163686D656E74733B0A0A2020202020202020202020202F2F204E657720636F6D';
wwv_flow_api.g_varchar2_table(553) := '6D656E742077617320637265617465640A2020202020202020202020207D20656C7365207B0A2020202020202020202020202020202070726F66696C655069637475726555524C203D20746869732E6F7074696F6E732E70726F66696C65506963747572';
wwv_flow_api.g_varchar2_table(554) := '6555524C3B0A20202020202020202020202020202020757365724964203D20746869732E6F7074696F6E732E63726561746F723B0A202020202020202020202020202020206174746163686D656E7473203D205B5D3B0A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(555) := '0A0A2020202020202020202020207661722070726F66696C6550696374757265203D20746869732E63726561746550726F66696C6550696374757265456C656D656E742870726F66696C655069637475726555524C2C20757365724964293B0A0A202020';
wwv_flow_api.g_varchar2_table(556) := '2020202020202020202F2F204E657720636F6D6D656E740A20202020202020202020202076617220746578746172656157726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20277465';
wwv_flow_api.g_varchar2_table(557) := '7874617265612D77726170706572270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20436F6E74726F6C20726F770A20202020202020202020202076617220636F6E74726F6C526F77203D202428273C6469762F3E272C';
wwv_flow_api.g_varchar2_table(558) := '207B0A2020202020202020202020202020202027636C617373273A2027636F6E74726F6C2D726F77270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2054657874617265610A2020202020202020202020207661722074';
wwv_flow_api.g_varchar2_table(559) := '65787461726561203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20277465787461726561272C0A2020202020202020202020202020202027646174612D706C616365686F6C646572273A20746869';
wwv_flow_api.g_varchar2_table(560) := '732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E7465787461726561506C616365686F6C64657254657874292C0A20202020202020202020202020202020636F6E74656E746564697461626C653A2074727565';
wwv_flow_api.g_varchar2_table(561) := '0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2053657474696E672074686520696E697469616C2068656967687420666F72207468652074657874617265610A202020202020202020202020746869732E61646A757374';
wwv_flow_api.g_varchar2_table(562) := '54657874617265614865696768742874657874617265612C2066616C7365293B0A0A2020202020202020202020202F2F20436C6F736520627574746F6E0A20202020202020202020202076617220636C6F7365427574746F6E203D20746869732E637265';
wwv_flow_api.g_varchar2_table(563) := '617465436C6F7365427574746F6E28293B0A202020202020202020202020636C6F7365427574746F6E2E616464436C6173732827696E6C696E652D627574746F6E27293B0A0A2020202020202020202020202F2F205361766520627574746F6E0A202020';
wwv_flow_api.g_varchar2_table(564) := '2020202020202020207661722073617665427574746F6E436C617373203D206578697374696E67436F6D6D656E744964203F202775706461746527203A202773656E64273B0A2020202020202020202020207661722073617665427574746F6E54657874';
wwv_flow_api.g_varchar2_table(565) := '203D206578697374696E67436F6D6D656E744964203F20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E736176655465787429203A20746869732E6F7074696F6E732E74657874466F726D61747465';
wwv_flow_api.g_varchar2_table(566) := '7228746869732E6F7074696F6E732E73656E6454657874293B0A2020202020202020202020207661722073617665427574746F6E203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A207361766542';
wwv_flow_api.g_varchar2_table(567) := '7574746F6E436C617373202B2027207361766520686967686C696768742D6261636B67726F756E64272C0A202020202020202020202020202020202774657874273A2073617665427574746F6E546578740A2020202020202020202020207D293B0A2020';
wwv_flow_api.g_varchar2_table(568) := '2020202020202020202073617665427574746F6E2E6461746128276F726967696E616C2D636F6E74656E74272C2073617665427574746F6E54657874293B0A202020202020202020202020636F6E74726F6C526F772E617070656E642873617665427574';
wwv_flow_api.g_varchar2_table(569) := '746F6E293B0A0A2020202020202020202020202F2F2044656C65746520627574746F6E0A2020202020202020202020206966286578697374696E67436F6D6D656E74496420262620746869732E6973416C6C6F776564546F44656C657465286578697374';
wwv_flow_api.g_varchar2_table(570) := '696E67436F6D6D656E7449642929207B0A0A202020202020202020202020202020202F2F2044656C65746520627574746F6E0A202020202020202020202020202020207661722064656C657465427574746F6E54657874203D20746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(571) := '6E732E74657874466F726D617474657228746869732E6F7074696F6E732E64656C65746554657874293B0A202020202020202020202020202020207661722064656C657465427574746F6E203D202428273C7370616E2F3E272C207B0A20202020202020';
wwv_flow_api.g_varchar2_table(572) := '2020202020202020202020202027636C617373273A202764656C65746520656E61626C6564272C0A2020202020202020202020202020202020202020746578743A2064656C657465427574746F6E546578740A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(573) := '292E63737328276261636B67726F756E642D636F6C6F72272C20746869732E6F7074696F6E732E64656C657465427574746F6E436F6C6F72293B0A2020202020202020202020202020202064656C657465427574746F6E2E6461746128276F726967696E';
wwv_flow_api.g_varchar2_table(574) := '616C2D636F6E74656E74272C2064656C657465427574746F6E54657874293B0A20202020202020202020202020202020636F6E74726F6C526F772E617070656E642864656C657465427574746F6E293B0A2020202020202020202020207D0A0A20202020';
wwv_flow_api.g_varchar2_table(575) := '2020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A0A202020202020202020202020202020202F2F2055706C6F616420627574746F6E730A202020202020202020202020202020202F2F203D';
wwv_flow_api.g_varchar2_table(576) := '3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A202020202020202020202020202020207661722075706C6F6164427574746F6E203D202428273C7370616E2F3E272C207B0A202020202020202020202020202020202020202027636C617373273A2027656E61626C';
wwv_flow_api.g_varchar2_table(577) := '65642075706C6F6164270A202020202020202020202020202020207D293B0A202020202020202020202020202020207661722075706C6F616449636F6E203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C61';
wwv_flow_api.g_varchar2_table(578) := '7373273A202766612066612D7061706572636C6970270A202020202020202020202020202020207D293B0A202020202020202020202020202020207661722066696C65496E707574203D202428273C696E7075742F3E272C207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(579) := '20202020202020202020202774797065273A202766696C65272C0A2020202020202020202020202020202020202020276D756C7469706C65273A20276D756C7469706C65272C0A202020202020202020202020202020202020202027646174612D726F6C';
wwv_flow_api.g_varchar2_table(580) := '65273A20276E6F6E6527202F2F2050726576656E74206A71756572792D6D6F62696C6520666F7220616464696E6720636C61737365730A202020202020202020202020202020207D293B0A0A20202020202020202020202020202020696628746869732E';
wwv_flow_api.g_varchar2_table(581) := '6F7074696F6E732E75706C6F616449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020202020202075706C6F616449636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E';
wwv_flow_api.g_varchar2_table(582) := '6F7074696F6E732E75706C6F616449636F6E55524C2B27222927293B0A202020202020202020202020202020202020202075706C6F616449636F6E2E616464436C6173732827696D61676527293B0A202020202020202020202020202020207D0A202020';
wwv_flow_api.g_varchar2_table(583) := '2020202020202020202020202075706C6F6164427574746F6E2E617070656E642875706C6F616449636F6E292E617070656E642866696C65496E707574293B0A0A202020202020202020202020202020202F2F204D61696E2075706C6F61642062757474';
wwv_flow_api.g_varchar2_table(584) := '6F6E0A20202020202020202020202020202020766172206D61696E55706C6F6164427574746F6E203D2075706C6F6164427574746F6E2E636C6F6E6528293B0A202020202020202020202020202020206D61696E55706C6F6164427574746F6E2E646174';
wwv_flow_api.g_varchar2_table(585) := '6128276F726967696E616C2D636F6E74656E74272C206D61696E55706C6F6164427574746F6E2E6368696C6472656E2829293B0A20202020202020202020202020202020636F6E74726F6C526F772E617070656E64286D61696E55706C6F616442757474';
wwv_flow_api.g_varchar2_table(586) := '6F6E293B0A0A202020202020202020202020202020202F2F20496E6C696E652075706C6F616420627574746F6E20666F72206D61696E20636F6D6D656E74696E67206669656C640A2020202020202020202020202020202069662869734D61696E29207B';
wwv_flow_api.g_varchar2_table(587) := '0A20202020202020202020202020202020202020207465787461726561577261707065722E617070656E642875706C6F6164427574746F6E2E636C6F6E6528292E616464436C6173732827696E6C696E652D627574746F6E2729293B0A20202020202020';
wwv_flow_api.g_varchar2_table(588) := '2020202020202020207D0A0A202020202020202020202020202020202F2F204174746163686D656E747320636F6E7461696E65720A202020202020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A2020202020';
wwv_flow_api.g_varchar2_table(589) := '2020202020202020202020766172206174746163686D656E7473436F6E7461696E6572203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A20276174746163686D656E7473272C0A20202020';
wwv_flow_api.g_varchar2_table(590) := '2020202020202020202020207D293B0A2020202020202020202020202020202024286174746163686D656E7473292E656163682866756E6374696F6E28696E6465782C206174746163686D656E7429207B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(591) := '2020766172206174746163686D656E74546167203D2073656C662E6372656174654174746163686D656E74546167456C656D656E74286174746163686D656E742C2074727565293B0A20202020202020202020202020202020202020206174746163686D';
wwv_flow_api.g_varchar2_table(592) := '656E7473436F6E7461696E65722E617070656E64286174746163686D656E74546167293B0A202020202020202020202020202020207D293B0A20202020202020202020202020202020636F6E74726F6C526F772E617070656E64286174746163686D656E';
wwv_flow_api.g_varchar2_table(593) := '7473436F6E7461696E6572293B0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F20506F70756C6174652074686520656C656D656E740A2020202020202020202020207465787461726561577261707065722E617070656E64';
wwv_flow_api.g_varchar2_table(594) := '28636C6F7365427574746F6E292E617070656E64287465787461726561292E617070656E6428636F6E74726F6C526F77293B0A202020202020202020202020636F6D6D656E74696E674669656C642E617070656E642870726F66696C6550696374757265';
wwv_flow_api.g_varchar2_table(595) := '292E617070656E6428746578746172656157726170706572293B0A0A0A202020202020202020202020696628706172656E74496429207B0A0A202020202020202020202020202020202F2F205365742074686520706172656E7420696420746F20746865';
wwv_flow_api.g_varchar2_table(596) := '206669656C64206966206E65636573736172790A2020202020202020202020202020202074657874617265612E617474722827646174612D706172656E74272C20706172656E744964293B0A0A202020202020202020202020202020202F2F2041707065';
wwv_flow_api.g_varchar2_table(597) := '6E64207265706C792D746F20746167206966206E65636573736172790A2020202020202020202020202020202076617220706172656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B706172656E7449645D3B0A2020202020202020';
wwv_flow_api.g_varchar2_table(598) := '2020202020202020696628706172656E744D6F64656C2E706172656E7429207B0A202020202020202020202020202020202020202074657874617265612E68746D6C2827266E6273703B27293B202020202F2F204E656564656420746F20736574207468';
wwv_flow_api.g_varchar2_table(599) := '6520637572736F7220746F20636F727265637420706C6163650A0A20202020202020202020202020202020202020202F2F204372656174696E6720746865207265706C792D746F207461670A202020202020202020202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(600) := '7265706C79546F4E616D65203D20274027202B20706172656E744D6F64656C2E66756C6C6E616D653B0A2020202020202020202020202020202020202020766172207265706C79546F546167203D20746869732E637265617465546167456C656D656E74';
wwv_flow_api.g_varchar2_table(601) := '287265706C79546F4E616D652C20277265706C792D746F272C20706172656E744D6F64656C2E63726561746F722C207B0A20202020202020202020202020202020202020202020202027646174612D757365722D6964273A20706172656E744D6F64656C';
wwv_flow_api.g_varchar2_table(602) := '2E63726561746F720A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020202020202074657874617265612E70726570656E64287265706C79546F546167293B0A202020202020202020202020202020207D';
wwv_flow_api.g_varchar2_table(603) := '0A2020202020202020202020207D0A0A2020202020202020202020202F2F2050696E67696E672075736572730A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C6550696E67696E6729207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(604) := '20202020202074657874617265612E74657874636F6D706C657465285B7B0A20202020202020202020202020202020202020206D617463683A202F285E7C5C732940285B5E405D2A29242F692C0A2020202020202020202020202020202020202020696E';
wwv_flow_api.g_varchar2_table(605) := '6465783A20322C0A20202020202020202020202020202020202020207365617263683A2066756E6374696F6E20287465726D2C2063616C6C6261636B29207B0A2020202020202020202020202020202020202020202020207465726D203D2073656C662E';
wwv_flow_api.g_varchar2_table(606) := '6E6F726D616C697A65537061636573287465726D293B0A2020202020202020202020202020202020202020202020200A2020202020202020202020202020202020202020202020202F2F2052657475726E20656D707479206172726179206F6E20657272';
wwv_flow_api.g_varchar2_table(607) := '6F720A202020202020202020202020202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A2020202020202020202020202020202020202020202020202020202063616C6C6261636B285B5D293B0A202020202020';
wwv_flow_api.g_varchar2_table(608) := '2020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202020202073656C662E6F7074696F6E732E7365617263685573657273287465726D2C2063616C6C6261636B2C206572726F72293B0A202020202020';
wwv_flow_api.g_varchar2_table(609) := '20202020202020202020202020207D2C0A202020202020202020202020202020202020202074656D706C6174653A2066756E6374696F6E287573657229207B0A202020202020202020202020202020202020202020202020766172207772617070657220';
wwv_flow_api.g_varchar2_table(610) := '3D202428273C6469762F3E27293B0A0A2020202020202020202020202020202020202020202020207661722070726F66696C6550696374757265456C203D2073656C662E63726561746550726F66696C6550696374757265456C656D656E742875736572';
wwv_flow_api.g_varchar2_table(611) := '2E70726F66696C655F706963747572655F75726C293B0A0A2020202020202020202020202020202020202020202020207661722064657461696C73456C203D202428273C6469762F3E272C207B0A20202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(612) := '20202020202027636C617373273A202764657461696C73272C0A2020202020202020202020202020202020202020202020207D293B0A202020202020202020202020202020202020202020202020766172206E616D65456C203D202428273C6469762F3E';
wwv_flow_api.g_varchar2_table(613) := '272C207B0A2020202020202020202020202020202020202020202020202020202027636C617373273A20276E616D65272C0A2020202020202020202020202020202020202020202020207D292E68746D6C28757365722E66756C6C6E616D65293B0A0A20';
wwv_flow_api.g_varchar2_table(614) := '202020202020202020202020202020202020202020202076617220656D61696C456C203D202428273C6469762F3E272C207B0A2020202020202020202020202020202020202020202020202020202027636C617373273A2027656D61696C272C0A202020';
wwv_flow_api.g_varchar2_table(615) := '2020202020202020202020202020202020202020207D292E68746D6C28757365722E656D61696C293B0A0A20202020202020202020202020202020202020202020202069662028757365722E656D61696C29207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(616) := '2020202020202020202020202064657461696C73456C2E617070656E64286E616D65456C292E617070656E6428656D61696C456C293B0A2020202020202020202020202020202020202020202020207D20656C7365207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(617) := '2020202020202020202020202020202064657461696C73456C2E616464436C61737328276E6F2D656D61696C27290A2020202020202020202020202020202020202020202020202020202064657461696C73456C2E617070656E64286E616D65456C290A';
wwv_flow_api.g_varchar2_table(618) := '2020202020202020202020202020202020202020202020207D0A0A202020202020202020202020202020202020202020202020777261707065722E617070656E642870726F66696C6550696374757265456C292E617070656E642864657461696C73456C';
wwv_flow_api.g_varchar2_table(619) := '293B0A20202020202020202020202020202020202020202020202072657475726E20777261707065722E68746D6C28293B0A20202020202020202020202020202020202020207D2C0A20202020202020202020202020202020202020207265706C616365';
wwv_flow_api.g_varchar2_table(620) := '3A2066756E6374696F6E20287573657229207B0A20202020202020202020202020202020202020202020202076617220746167203D2073656C662E637265617465546167456C656D656E7428274027202B20757365722E66756C6C6E616D652C20277069';
wwv_flow_api.g_varchar2_table(621) := '6E67272C20757365722E69642C207B0A2020202020202020202020202020202020202020202020202020202027646174612D757365722D6964273A20757365722E69640A2020202020202020202020202020202020202020202020207D293B0A20202020';
wwv_flow_api.g_varchar2_table(622) := '202020202020202020202020202020202020202072657475726E20272027202B207461675B305D2E6F7574657248544D4C202B202720273B0A20202020202020202020202020202020202020207D2C0A202020202020202020202020202020207D5D2C20';
wwv_flow_api.g_varchar2_table(623) := '7B0A2020202020202020202020202020202020202020617070656E64546F3A20272E6A71756572792D636F6D6D656E7473272C0A202020202020202020202020202020202020202064726F70646F776E436C6173734E616D653A202764726F70646F776E';
wwv_flow_api.g_varchar2_table(624) := '206175746F636F6D706C657465272C0A20202020202020202020202020202020202020206D6178436F756E743A20352C0A20202020202020202020202020202020202020207269676874456467654F66667365743A20302C0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(625) := '2020202020202020206465626F756E63653A203235300A202020202020202020202020202020207D293B0A0A0A202020202020202020202020202020202F2F204F5645524944452054455854434F4D504C4554452044524F50444F574E20504F53495449';
wwv_flow_api.g_varchar2_table(626) := '4F4E494E470A0A20202020202020202020202020202020242E666E2E74657874636F6D706C6574652E44726F70646F776E2E70726F746F747970652E72656E646572203D2066756E6374696F6E287A69707065644461746129207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(627) := '20202020202020202020202076617220636F6E74656E747348746D6C203D20746869732E5F6275696C64436F6E74656E7473287A697070656444617461293B0A202020202020202020202020202020202020202076617220756E7A697070656444617461';
wwv_flow_api.g_varchar2_table(628) := '203D20242E6D6170287A6970706564446174612C2066756E6374696F6E20286429207B2072657475726E20642E76616C75653B207D293B0A2020202020202020202020202020202020202020696620287A6970706564446174612E6C656E67746829207B';
wwv_flow_api.g_varchar2_table(629) := '0A20202020202020202020202020202020202020202020766172207374726174656779203D207A6970706564446174615B305D2E73747261746567793B0A202020202020202020202020202020202020202020206966202873747261746567792E696429';
wwv_flow_api.g_varchar2_table(630) := '207B0A202020202020202020202020202020202020202020202020746869732E24656C2E617474722827646174612D7374726174656779272C2073747261746567792E6964293B0A202020202020202020202020202020202020202020207D20656C7365';
wwv_flow_api.g_varchar2_table(631) := '207B0A202020202020202020202020202020202020202020202020746869732E24656C2E72656D6F7665417474722827646174612D737472617465677927293B0A202020202020202020202020202020202020202020207D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(632) := '2020202020202020202020746869732E5F72656E64657248656164657228756E7A697070656444617461293B0A20202020202020202020202020202020202020202020746869732E5F72656E646572466F6F74657228756E7A697070656444617461293B';
wwv_flow_api.g_varchar2_table(633) := '0A2020202020202020202020202020202020202020202069662028636F6E74656E747348746D6C29207B0A202020202020202020202020202020202020202020202020746869732E5F72656E646572436F6E74656E747328636F6E74656E747348746D6C';
wwv_flow_api.g_varchar2_table(634) := '293B0A202020202020202020202020202020202020202020202020746869732E5F666974546F426F74746F6D28293B0A202020202020202020202020202020202020202020202020746869732E5F666974546F526967687428293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(635) := '20202020202020202020202020202020746869732E5F6163746976617465496E64657865644974656D28293B0A202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020202020746869732E5F736574';
wwv_flow_api.g_varchar2_table(636) := '5363726F6C6C28293B0A20202020202020202020202020202020202020207D20656C73652069662028746869732E6E6F526573756C74734D65737361676529207B0A20202020202020202020202020202020202020202020746869732E5F72656E646572';
wwv_flow_api.g_varchar2_table(637) := '4E6F526573756C74734D65737361676528756E7A697070656444617461293B0A20202020202020202020202020202020202020207D20656C73652069662028746869732E73686F776E29207B0A2020202020202020202020202020202020202020202074';
wwv_flow_api.g_varchar2_table(638) := '6869732E6465616374697661746528293B0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202F2F20435553544F4D20434F44450A20202020202020202020202020202020202020202F2F203D';
wwv_flow_api.g_varchar2_table(639) := '3D3D3D3D3D3D3D3D3D3D0A0A20202020202020202020202020202020202020202F2F2041646A75737420766572746963616C20706F736974696F6E0A202020202020202020202020202020202020202076617220746F70203D207061727365496E742874';
wwv_flow_api.g_varchar2_table(640) := '6869732E24656C2E6373732827746F70272929202B2073656C662E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F7028293B0A2020202020202020202020202020202020202020746869732E24656C2E6373732827746F';
wwv_flow_api.g_varchar2_table(641) := '70272C20746F70293B0A0A20202020202020202020202020202020202020202F2F2041646A75737420686F72697A6F6E74616C20706F736974696F6E0A2020202020202020202020202020202020202020766172206F726967696E616C4C656674203D20';
wwv_flow_api.g_varchar2_table(642) := '746869732E24656C2E63737328276C65667427293B0A2020202020202020202020202020202020202020746869732E24656C2E63737328276C656674272C2030293B202020202F2F204C656674206D7573742062652073657420746F203020696E206F72';
wwv_flow_api.g_varchar2_table(643) := '64657220746F2067657420746865207265616C207769647468206F662074686520656C0A2020202020202020202020202020202020202020766172206D61784C656674203D2073656C662E24656C2E77696474682829202D20746869732E24656C2E6F75';
wwv_flow_api.g_varchar2_table(644) := '746572576964746828293B0A2020202020202020202020202020202020202020766172206C656674203D204D6174682E6D696E286D61784C6566742C207061727365496E74286F726967696E616C4C65667429293B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(645) := '202020202020746869732E24656C2E63737328276C656674272C206C656674293B0A0A20202020202020202020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D0A202020202020202020202020202020207D0A0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(646) := '2020202020202F2F204F5645524944452054455854434F4D504C45544520434F4E54454E544544495441424C4520534B49505345415243482046554E4354494F4E205748454E205553494E4720414C54202B206261636B73706163650A0A202020202020';
wwv_flow_api.g_varchar2_table(647) := '20202020202020202020242E666E2E74657874636F6D706C6574652E436F6E74656E744564697461626C652E70726F746F747970652E5F736B6970536561726368203D2066756E6374696F6E28636C69636B4576656E7429207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(648) := '20202020202020202020207377697463682028636C69636B4576656E742E6B6579436F646529207B0A2020202020202020202020202020202020202020202020206361736520393A20202F2F205441420A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(649) := '2020202020636173652031333A202F2F20454E5445520A202020202020202020202020202020202020202020202020636173652031363A202F2F2053484946540A202020202020202020202020202020202020202020202020636173652031373A202F2F';
wwv_flow_api.g_varchar2_table(650) := '204354524C0A2020202020202020202020202020202020202020202020202F2F636173652031383A202F2F20414C540A202020202020202020202020202020202020202020202020636173652033333A202F2F205041474555500A202020202020202020';
wwv_flow_api.g_varchar2_table(651) := '202020202020202020202020202020636173652033343A202F2F2050414745444F574E0A202020202020202020202020202020202020202020202020636173652034303A202F2F20444F574E0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(652) := '20636173652033383A202F2F2055500A202020202020202020202020202020202020202020202020636173652032373A202F2F204553430A2020202020202020202020202020202020202020202020202020202072657475726E20747275653B0A202020';
wwv_flow_api.g_varchar2_table(653) := '20202020202020202020202020202020207D0A202020202020202020202020202020202020202069662028636C69636B4576656E742E6374726C4B657929207377697463682028636C69636B4576656E742E6B6579436F646529207B0A20202020202020';
wwv_flow_api.g_varchar2_table(654) := '2020202020202020202020202020202020636173652037383A202F2F204374726C2D4E0A202020202020202020202020202020202020202020202020636173652038303A202F2F204374726C2D500A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(655) := '2020202020202072657475726E20747275653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A20202020202020202020202072657475726E20636F6D6D656E';
wwv_flow_api.g_varchar2_table(656) := '74696E674669656C643B0A20202020202020207D2C0A0A20202020202020206372656174654E617669676174696F6E456C656D656E743A2066756E6374696F6E2829207B0A202020202020202020202020766172206E617669676174696F6E456C203D20';
wwv_flow_api.g_varchar2_table(657) := '2428273C756C2F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E617669676174696F6E270A2020202020202020202020207D293B0A202020202020202020202020766172206E617669676174696F6E57726170706572';
wwv_flow_api.g_varchar2_table(658) := '203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E617669676174696F6E2D77726170706572270A2020202020202020202020207D293B0A2020202020202020202020206E617669676174696F';
wwv_flow_api.g_varchar2_table(659) := '6E456C2E617070656E64286E617669676174696F6E57726170706572293B0A0A2020202020202020202020202F2F204E65776573740A202020202020202020202020766172206E6577657374203D202428273C6C692F3E272C207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(660) := '2020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E657765737454657874292C0A2020202020202020202020202020202027646174612D736F72742D6B6579273A20';
wwv_flow_api.g_varchar2_table(661) := '276E6577657374272C0A2020202020202020202020202020202027646174612D636F6E7461696E65722D6E616D65273A2027636F6D6D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204F6C646573740A20';
wwv_flow_api.g_varchar2_table(662) := '2020202020202020202020766172206F6C64657374203D202428273C6C692F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6F';
wwv_flow_api.g_varchar2_table(663) := '6C6465737454657874292C0A2020202020202020202020202020202027646174612D736F72742D6B6579273A20276F6C64657374272C0A2020202020202020202020202020202027646174612D636F6E7461696E65722D6E616D65273A2027636F6D6D65';
wwv_flow_api.g_varchar2_table(664) := '6E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20506F70756C61720A20202020202020202020202076617220706F70756C6172203D202428273C6C692F3E272C207B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(665) := '746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E706F70756C617254657874292C0A2020202020202020202020202020202027646174612D736F72742D6B6579273A2027706F70756C61';
wwv_flow_api.g_varchar2_table(666) := '72697479272C0A2020202020202020202020202020202027646174612D636F6E7461696E65722D6E616D65273A2027636F6D6D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204174746163686D656E7473';
wwv_flow_api.g_varchar2_table(667) := '0A202020202020202020202020766172206174746163686D656E7473203D202428273C6C692F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F70';
wwv_flow_api.g_varchar2_table(668) := '74696F6E732E6174746163686D656E747354657874292C0A2020202020202020202020202020202027646174612D736F72742D6B6579273A20276174746163686D656E7473272C0A2020202020202020202020202020202027646174612D636F6E746169';
wwv_flow_api.g_varchar2_table(669) := '6E65722D6E616D65273A20276174746163686D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204174746163686D656E74732069636F6E0A202020202020202020202020766172206174746163686D656E74';
wwv_flow_api.g_varchar2_table(670) := '7349636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7061706572636C6970270A2020202020202020202020207D293B0A202020202020202020202020696628746869732E6F';
wwv_flow_api.g_varchar2_table(671) := '7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020206174746163686D656E747349636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B74';
wwv_flow_api.g_varchar2_table(672) := '6869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927293B0A202020202020202020202020202020206174746163686D656E747349636F6E2E616464436C6173732827696D61676527293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(673) := '7D0A2020202020202020202020206174746163686D656E74732E70726570656E64286174746163686D656E747349636F6E293B0A0A0A2020202020202020202020202F2F20526573706F6E73697665206E617669676174696F6E0A202020202020202020';
wwv_flow_api.g_varchar2_table(674) := '2020207661722064726F70646F776E4E617669676174696F6E57726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E617669676174696F6E2D7772617070657220726573706F6E';
wwv_flow_api.g_varchar2_table(675) := '73697665270A2020202020202020202020207D293B0A2020202020202020202020207661722064726F70646F776E4E617669676174696F6E203D202428273C756C2F3E272C207B0A2020202020202020202020202020202027636C617373273A20276472';
wwv_flow_api.g_varchar2_table(676) := '6F70646F776E270A2020202020202020202020207D293B0A2020202020202020202020207661722064726F70646F776E5469746C65203D202428273C6C692F3E272C207B0A2020202020202020202020202020202027636C617373273A20277469746C65';
wwv_flow_api.g_varchar2_table(677) := '270A2020202020202020202020207D293B0A2020202020202020202020207661722064726F70646F776E5469746C65486561646572203D202428273C6865616465722F3E27293B0A0A20202020202020202020202064726F70646F776E5469746C652E61';
wwv_flow_api.g_varchar2_table(678) := '7070656E642864726F70646F776E5469746C65486561646572293B0A20202020202020202020202064726F70646F776E4E617669676174696F6E577261707065722E617070656E642864726F70646F776E5469746C65293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(679) := '2064726F70646F776E4E617669676174696F6E577261707065722E617070656E642864726F70646F776E4E617669676174696F6E293B0A2020202020202020202020206E617669676174696F6E456C2E617070656E642864726F70646F776E4E61766967';
wwv_flow_api.g_varchar2_table(680) := '6174696F6E57726170706572293B0A0A0A2020202020202020202020202F2F20506F70756C61746520656C656D656E74730A2020202020202020202020206E617669676174696F6E577261707065722E617070656E64286E6577657374292E617070656E';
wwv_flow_api.g_varchar2_table(681) := '64286F6C64657374293B0A20202020202020202020202064726F70646F776E4E617669676174696F6E2E617070656E64286E65776573742E636C6F6E652829292E617070656E64286F6C646573742E636C6F6E652829293B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(682) := '2020696628746869732E6F7074696F6E732E656E61626C655265706C79696E67207C7C20746869732E6F7074696F6E732E656E61626C655570766F74696E6729207B0A202020202020202020202020202020206E617669676174696F6E57726170706572';
wwv_flow_api.g_varchar2_table(683) := '2E617070656E6428706F70756C6172293B0A2020202020202020202020202020202064726F70646F776E4E617669676174696F6E2E617070656E6428706F70756C61722E636C6F6E652829293B0A2020202020202020202020207D0A2020202020202020';
wwv_flow_api.g_varchar2_table(684) := '20202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A202020202020202020202020202020206E617669676174696F6E577261707065722E617070656E64286174746163686D656E7473293B0A20202020';
wwv_flow_api.g_varchar2_table(685) := '20202020202020202020202064726F70646F776E4E617669676174696F6E577261707065722E617070656E64286174746163686D656E74732E636C6F6E652829293B0A2020202020202020202020207D0A0A202020202020202020202020696628746869';
wwv_flow_api.g_varchar2_table(686) := '732E6F7074696F6E732E666F726365526573706F6E736976652920746869732E666F726365526573706F6E7369766528293B0A20202020202020202020202072657475726E206E617669676174696F6E456C3B0A20202020202020207D2C0A0A20202020';
wwv_flow_api.g_varchar2_table(687) := '202020206372656174655370696E6E65723A2066756E6374696F6E28696E6C696E6529207B0A202020202020202020202020766172207370696E6E6572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373';
wwv_flow_api.g_varchar2_table(688) := '273A20277370696E6E6572270A2020202020202020202020207D293B0A202020202020202020202020696628696E6C696E6529207370696E6E65722E616464436C6173732827696E6C696E6527293B0A0A20202020202020202020202076617220737069';
wwv_flow_api.g_varchar2_table(689) := '6E6E657249636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7370696E6E65722066612D7370696E270A2020202020202020202020207D293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(690) := '696628746869732E6F7074696F6E732E7370696E6E657249636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020207370696E6E657249636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C282227';
wwv_flow_api.g_varchar2_table(691) := '2B746869732E6F7074696F6E732E7370696E6E657249636F6E55524C2B27222927293B0A202020202020202020202020202020207370696E6E657249636F6E2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A202020';
wwv_flow_api.g_varchar2_table(692) := '2020202020202020207370696E6E65722E68746D6C287370696E6E657249636F6E293B0A20202020202020202020202072657475726E207370696E6E65723B0A20202020202020207D2C0A0A2020202020202020637265617465436C6F7365427574746F';
wwv_flow_api.g_varchar2_table(693) := '6E3A2066756E6374696F6E28636C6173734E616D6529207B0A20202020202020202020202076617220636C6F7365427574746F6E203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A20636C617373';
wwv_flow_api.g_varchar2_table(694) := '4E616D65207C7C2027636C6F7365270A2020202020202020202020207D293B0A0A2020202020202020202020207661722069636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D';
wwv_flow_api.g_varchar2_table(695) := '74696D6573270A2020202020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E636C6F736549636F6E55524C2E6C656E67746829207B0A2020202020202020202020202020202069636F6E2E6373732827';
wwv_flow_api.g_varchar2_table(696) := '6261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E636C6F736549636F6E55524C2B27222927293B0A2020202020202020202020202020202069636F6E2E616464436C6173732827696D61676527293B0A';
wwv_flow_api.g_varchar2_table(697) := '2020202020202020202020207D0A0A202020202020202020202020636C6F7365427574746F6E2E68746D6C2869636F6E293B0A0A20202020202020202020202072657475726E20636C6F7365427574746F6E3B0A20202020202020207D2C0A0A20202020';
wwv_flow_api.g_varchar2_table(698) := '20202020637265617465436F6D6D656E74456C656D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C29207B0A0A2020202020202020202020202F2F20436F6D6D656E7420636F6E7461696E657220656C656D656E740A20202020202020';
wwv_flow_api.g_varchar2_table(699) := '202020202076617220636F6D6D656E74456C203D202428273C6C692F3E272C207B0A2020202020202020202020202020202027646174612D6964273A20636F6D6D656E744D6F64656C2E69642C0A2020202020202020202020202020202027636C617373';
wwv_flow_api.g_varchar2_table(700) := '273A2027636F6D6D656E74270A2020202020202020202020207D292E6461746128276D6F64656C272C20636F6D6D656E744D6F64656C293B0A0A202020202020202020202020696628636F6D6D656E744D6F64656C2E6372656174656442794375727265';
wwv_flow_api.g_varchar2_table(701) := '6E74557365722920636F6D6D656E74456C2E616464436C617373282762792D63757272656E742D7573657227293B0A202020202020202020202020696628636F6D6D656E744D6F64656C2E63726561746564427941646D696E2920636F6D6D656E74456C';
wwv_flow_api.g_varchar2_table(702) := '2E616464436C617373282762792D61646D696E27293B0A0A2020202020202020202020202F2F204368696C6420636F6D6D656E74730A202020202020202020202020766172206368696C64436F6D6D656E7473203D202428273C756C2F3E272C207B0A20';
wwv_flow_api.g_varchar2_table(703) := '20202020202020202020202020202027636C617373273A20276368696C642D636F6D6D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20436F6D6D656E7420777261707065720A2020202020202020202020';
wwv_flow_api.g_varchar2_table(704) := '2076617220636F6D6D656E7457726170706572203D20746869732E637265617465436F6D6D656E7457726170706572456C656D656E7428636F6D6D656E744D6F64656C293B0A0A202020202020202020202020636F6D6D656E74456C2E617070656E6428';
wwv_flow_api.g_varchar2_table(705) := '636F6D6D656E7457726170706572293B0A2020202020202020202020202F2A696628636F6D6D656E744D6F64656C2E706172656E74203D3D206E756C6C292A2F20636F6D6D656E74456C2E617070656E64286368696C64436F6D6D656E7473293B0A2020';
wwv_flow_api.g_varchar2_table(706) := '2020202020202020202072657475726E20636F6D6D656E74456C3B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E7457726170706572456C656D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2920';
wwv_flow_api.g_varchar2_table(707) := '7B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202076617220636F6D6D656E7457726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C6173';
wwv_flow_api.g_varchar2_table(708) := '73273A2027636F6D6D656E742D77726170706572270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2050726F66696C6520706963747572650A2020202020202020202020207661722070726F66696C6550696374757265';
wwv_flow_api.g_varchar2_table(709) := '203D20746869732E63726561746550726F66696C6550696374757265456C656D656E7428636F6D6D656E744D6F64656C2E70726F66696C655069637475726555524C2C20636F6D6D656E744D6F64656C2E63726561746F72293B0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(710) := '202020202F2F2054696D650A2020202020202020202020207661722074696D65203D202428273C74696D652F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74696D65466F726D61747465722863';
wwv_flow_api.g_varchar2_table(711) := '6F6D6D656E744D6F64656C2E63726561746564292C0A2020202020202020202020202020202027646174612D6F726967696E616C273A20636F6D6D656E744D6F64656C2E637265617465640A2020202020202020202020207D293B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(712) := '20202020202F2F20436F6D6D656E742068656164657220656C656D656E740A20202020202020202020202076617220636F6D6D656E74486561646572456C203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C6173';
wwv_flow_api.g_varchar2_table(713) := '73273A2027636F6D6D656E742D686561646572272C0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204E616D6520656C656D656E740A202020202020202020202020766172206E616D65456C203D202428273C7370616E';
wwv_flow_api.g_varchar2_table(714) := '2F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E616D65272C0A2020202020202020202020202020202027646174612D757365722D6964273A20636F6D6D656E744D6F64656C2E63726561746F722C0A202020202020';
wwv_flow_api.g_varchar2_table(715) := '202020202020202020202774657874273A20636F6D6D656E744D6F64656C2E63726561746564427943757272656E7455736572203F20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E796F75546578';
wwv_flow_api.g_varchar2_table(716) := '7429203A20636F6D6D656E744D6F64656C2E66756C6C6E616D650A2020202020202020202020207D293B0A202020202020202020202020636F6D6D656E74486561646572456C2E617070656E64286E616D65456C293B0A0A0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(717) := '202F2F20486967686C696768742061646D696E206E616D65730A202020202020202020202020696628636F6D6D656E744D6F64656C2E63726561746564427941646D696E29206E616D65456C2E616464436C6173732827686967686C696768742D666F6E';
wwv_flow_api.g_varchar2_table(718) := '742D626F6C6427293B0A0A2020202020202020202020202F2F2053686F77207265706C792D746F206E616D6520696620706172656E74206F6620706172656E74206578697374730A202020202020202020202020696628636F6D6D656E744D6F64656C2E';
wwv_flow_api.g_varchar2_table(719) := '706172656E7429207B0A2020202020202020202020202020202076617220706172656E74203D20746869732E636F6D6D656E7473427949645B636F6D6D656E744D6F64656C2E706172656E745D3B0A202020202020202020202020202020206966287061';
wwv_flow_api.g_varchar2_table(720) := '72656E742E706172656E7429207B0A2020202020202020202020202020202020202020766172207265706C79546F203D202428273C7370616E2F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A20277265';
wwv_flow_api.g_varchar2_table(721) := '706C792D746F272C0A2020202020202020202020202020202020202020202020202774657874273A20706172656E742E66756C6C6E616D652C0A20202020202020202020202020202020202020202020202027646174612D757365722D6964273A207061';
wwv_flow_api.g_varchar2_table(722) := '72656E742E63726561746F720A20202020202020202020202020202020202020207D293B0A0A20202020202020202020202020202020202020202F2F207265706C792069636F6E0A2020202020202020202020202020202020202020766172207265706C';
wwv_flow_api.g_varchar2_table(723) := '7949636F6E203D202428273C692F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A202766612066612D7368617265270A20202020202020202020202020202020202020207D293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(724) := '2020202020202020202020696628746869732E6F7074696F6E732E7265706C7949636F6E55524C2E6C656E67746829207B0A2020202020202020202020202020202020202020202020207265706C7949636F6E2E63737328276261636B67726F756E642D';
wwv_flow_api.g_varchar2_table(725) := '696D616765272C202775726C2822272B746869732E6F7074696F6E732E7265706C7949636F6E55524C2B27222927293B0A2020202020202020202020202020202020202020202020207265706C7949636F6E2E616464436C6173732827696D6167652729';
wwv_flow_api.g_varchar2_table(726) := '3B0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020207265706C79546F2E70726570656E64287265706C7949636F6E293B0A2020202020202020202020202020202020202020636F6D6D656E74';
wwv_flow_api.g_varchar2_table(727) := '486561646572456C2E617070656E64287265706C79546F293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F204E6577207461670A202020202020202020202020696628636F6D';
wwv_flow_api.g_varchar2_table(728) := '6D656E744D6F64656C2E69734E657729207B0A20202020202020202020202020202020766172206E6577546167203D202428273C7370616E2F3E272C207B0A202020202020202020202020202020202020202027636C617373273A20276E657720686967';
wwv_flow_api.g_varchar2_table(729) := '686C696768742D6261636B67726F756E64272C0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E657754657874290A2020202020';
wwv_flow_api.g_varchar2_table(730) := '20202020202020202020207D293B0A20202020202020202020202020202020636F6D6D656E74486561646572456C2E617070656E64286E6577546167293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2057726170706572';
wwv_flow_api.g_varchar2_table(731) := '0A2020202020202020202020207661722077726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A202777726170706572270A2020202020202020202020207D293B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(732) := '20202020202F2F20436F6E74656E740A2020202020202020202020202F2F203D3D3D3D3D3D3D0A0A20202020202020202020202076617220636F6E74656E74203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C61';
wwv_flow_api.g_varchar2_table(733) := '7373273A2027636F6E74656E74270A2020202020202020202020207D293B0A202020202020202020202020636F6E74656E742E68746D6C28746869732E676574466F726D6174746564436F6D6D656E74436F6E74656E7428636F6D6D656E744D6F64656C';
wwv_flow_api.g_varchar2_table(734) := '29293B0A0A2020202020202020202020202F2F204564697465642074696D657374616D700A202020202020202020202020696628636F6D6D656E744D6F64656C2E6D6F64696669656420262620636F6D6D656E744D6F64656C2E6D6F6469666965642021';
wwv_flow_api.g_varchar2_table(735) := '3D20636F6D6D656E744D6F64656C2E6372656174656429207B0A202020202020202020202020202020207661722065646974656454696D65203D20746869732E6F7074696F6E732E74696D65466F726D617474657228636F6D6D656E744D6F64656C2E6D';
wwv_flow_api.g_varchar2_table(736) := '6F646966696564293B0A2020202020202020202020202020202076617220656469746564203D202428273C74696D652F3E272C207B0A202020202020202020202020202020202020202027636C617373273A2027656469746564272C0A20202020202020';
wwv_flow_api.g_varchar2_table(737) := '20202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6564697465645465787429202B20272027202B2065646974656454696D652C0A202020202020202020';
wwv_flow_api.g_varchar2_table(738) := '202020202020202020202027646174612D6F726967696E616C273A20636F6D6D656E744D6F64656C2E6D6F6469666965640A202020202020202020202020202020207D293B0A20202020202020202020202020202020636F6E74656E742E617070656E64';
wwv_flow_api.g_varchar2_table(739) := '28656469746564293B0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F204174746163686D656E74730A2020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D0A0A20202020202020202020202076617220617474';
wwv_flow_api.g_varchar2_table(740) := '6163686D656E7473203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276174746163686D656E7473270A2020202020202020202020207D293B0A2020202020202020202020207661722061747461';
wwv_flow_api.g_varchar2_table(741) := '63686D656E745072657669657773203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20277072657669657773270A2020202020202020202020207D293B0A2020202020202020202020207661722061';
wwv_flow_api.g_varchar2_table(742) := '74746163686D656E7454616773203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A202774616773270A2020202020202020202020207D293B0A2020202020202020202020206174746163686D656E74';
wwv_flow_api.g_varchar2_table(743) := '732E617070656E64286174746163686D656E745072657669657773292E617070656E64286174746163686D656E7454616773293B0A0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747320';
wwv_flow_api.g_varchar2_table(744) := '262620636F6D6D656E744D6F64656C2E6861734174746163686D656E7473282929207B0A202020202020202020202020202020202428636F6D6D656E744D6F64656C2E6174746163686D656E7473292E656163682866756E6374696F6E28696E6465782C';
wwv_flow_api.g_varchar2_table(745) := '206174746163686D656E7429207B0A202020202020202020202020202020202020202076617220666F726D6174203D20756E646566696E65643B0A20202020202020202020202020202020202020207661722074797065203D20756E646566696E65643B';
wwv_flow_api.g_varchar2_table(746) := '0A0A20202020202020202020202020202020202020202F2F205479706520616E6420666F726D61740A20202020202020202020202020202020202020206966286174746163686D656E742E6D696D655F7479706529207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(747) := '202020202020202020202020766172206D696D65547970655061727473203D206174746163686D656E742E6D696D655F747970652E73706C697428272F27293B0A2020202020202020202020202020202020202020202020206966286D696D6554797065';
wwv_flow_api.g_varchar2_table(748) := '50617274732E6C656E677468203D3D203229207B0A20202020202020202020202020202020202020202020202020202020666F726D6174203D206D696D655479706550617274735B315D3B0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(749) := '2020202074797065203D206D696D655479706550617274735B305D3B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202F2F';
wwv_flow_api.g_varchar2_table(750) := '20507265766965770A202020202020202020202020202020202020202069662874797065203D3D2027696D61676527207C7C2074797065203D3D2027766964656F2729207B0A202020202020202020202020202020202020202020202020766172207072';
wwv_flow_api.g_varchar2_table(751) := '6576696577526F77203D202428273C6469762F3E27293B0A0A2020202020202020202020202020202020202020202020202F2F205072657669657720656C656D656E740A2020202020202020202020202020202020202020202020207661722070726576';
wwv_flow_api.g_varchar2_table(752) := '696577203D202428273C612F3E272C207B0A2020202020202020202020202020202020202020202020202020202027636C617373273A202770726576696577272C0A20202020202020202020202020202020202020202020202020202020687265663A20';
wwv_flow_api.g_varchar2_table(753) := '6174746163686D656E742E66696C652C0A202020202020202020202020202020202020202020202020202020207461726765743A20275F626C616E6B270A2020202020202020202020202020202020202020202020207D293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(754) := '202020202020202020202020202070726576696577526F772E68746D6C2870726576696577293B0A0A2020202020202020202020202020202020202020202020202F2F20436173653A20696D61676520707265766965770A202020202020202020202020';
wwv_flow_api.g_varchar2_table(755) := '20202020202020202020202069662874797065203D3D2027696D6167652729207B0A2020202020202020202020202020202020202020202020202020202076617220696D616765203D202428273C696D672F3E272C207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(756) := '20202020202020202020202020202020202020207372633A206174746163686D656E742E66696C650A202020202020202020202020202020202020202020202020202020207D293B0A202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(757) := '20707265766965772E68746D6C28696D616765293B0A0A2020202020202020202020202020202020202020202020202F2F20436173653A20766964656F20707265766965770A2020202020202020202020202020202020202020202020207D20656C7365';
wwv_flow_api.g_varchar2_table(758) := '207B0A2020202020202020202020202020202020202020202020202020202076617220766964656F203D202428273C766964656F2F3E272C207B0A20202020202020202020202020202020202020202020202020202020202020207372633A2061747461';
wwv_flow_api.g_varchar2_table(759) := '63686D656E742E66696C652C0A2020202020202020202020202020202020202020202020202020202020202020747970653A206174746163686D656E742E6D696D655F747970652C0A202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(760) := '2020202020636F6E74726F6C733A2027636F6E74726F6C73270A202020202020202020202020202020202020202020202020202020207D293B0A20202020202020202020202020202020202020202020202020202020707265766965772E68746D6C2876';
wwv_flow_api.g_varchar2_table(761) := '6964656F293B0A2020202020202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020202020206174746163686D656E7450726576696577732E617070656E642870726576696577526F77293B0A20202020';
wwv_flow_api.g_varchar2_table(762) := '202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202F2F2054616720656C656D656E740A2020202020202020202020202020202020202020766172206174746163686D656E74546167203D2073656C662E63';
wwv_flow_api.g_varchar2_table(763) := '72656174654174746163686D656E74546167456C656D656E74286174746163686D656E742C2066616C7365293B0A20202020202020202020202020202020202020206174746163686D656E74546167732E617070656E64286174746163686D656E745461';
wwv_flow_api.g_varchar2_table(764) := '67293B0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F20416374696F6E730A2020202020202020202020202F2F203D3D3D3D3D3D3D0A0A20202020202020202020202076';
wwv_flow_api.g_varchar2_table(765) := '617220616374696F6E73203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A2027616374696F6E73270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F205365706172';
wwv_flow_api.g_varchar2_table(766) := '61746F720A20202020202020202020202076617220736570617261746F72203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A2027736570617261746F72272C0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(767) := '2020746578743A2027C2B7270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F205265706C790A202020202020202020202020766172207265706C79203D202428273C627574746F6E2F3E272C207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(768) := '202020202020202027636C617373273A2027616374696F6E207265706C79272C0A202020202020202020202020202020202774797065273A2027627574746F6E272C0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E';
wwv_flow_api.g_varchar2_table(769) := '732E74657874466F726D617474657228746869732E6F7074696F6E732E7265706C7954657874290A2020202020202020202020207D293B0A0A2020202020202020202020202F2F205570766F74652069636F6E0A20202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(770) := '7570766F746549636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7468756D62732D7570270A2020202020202020202020207D293B0A20202020202020202020202069662874';
wwv_flow_api.g_varchar2_table(771) := '6869732E6F7074696F6E732E7570766F746549636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020207570766F746549636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E';
wwv_flow_api.g_varchar2_table(772) := '6F7074696F6E732E7570766F746549636F6E55524C2B27222927293B0A202020202020202020202020202020207570766F746549636F6E2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(773) := '20202F2F205570766F7465730A202020202020202020202020766172207570766F746573203D20746869732E6372656174655570766F7465456C656D656E7428636F6D6D656E744D6F64656C293B0A0A2020202020202020202020202F2F20417070656E';
wwv_flow_api.g_varchar2_table(774) := '6420627574746F6E7320666F7220616374696F6E7320746861742061726520656E61626C65640A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C655265706C79696E672920616374696F6E732E617070656E64287265';
wwv_flow_api.g_varchar2_table(775) := '706C79293B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C655570766F74696E672920616374696F6E732E617070656E64287570766F746573293B0A0A202020202020202020202020696628636F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(776) := '64656C2E63726561746564427943757272656E7455736572207C7C20746869732E6F7074696F6E732E63757272656E7455736572497341646D696E29207B0A202020202020202020202020202020207661722065646974427574746F6E203D202428273C';
wwv_flow_api.g_varchar2_table(777) := '627574746F6E2F3E272C207B0A202020202020202020202020202020202020202027636C617373273A2027616374696F6E2065646974272C0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874';
wwv_flow_api.g_varchar2_table(778) := '466F726D617474657228746869732E6F7074696F6E732E6564697454657874290A202020202020202020202020202020207D293B0A20202020202020202020202020202020616374696F6E732E617070656E642865646974427574746F6E293B0A202020';
wwv_flow_api.g_varchar2_table(779) := '2020202020202020207D0A0A2020202020202020202020202F2F20417070656E6420736570617261746F7273206265747765656E2074686520616374696F6E730A202020202020202020202020616374696F6E732E6368696C6472656E28292E65616368';
wwv_flow_api.g_varchar2_table(780) := '2866756E6374696F6E28696E6465782C20616374696F6E456C29207B0A20202020202020202020202020202020696628212428616374696F6E456C292E697328273A6C6173742D6368696C64272929207B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(781) := '20202428616374696F6E456C292E616674657228736570617261746F722E636C6F6E652829293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A0A202020202020202020202020777261707065722E617070656E';
wwv_flow_api.g_varchar2_table(782) := '6428636F6E74656E74293B0A202020202020202020202020777261707065722E617070656E64286174746163686D656E7473293B0A202020202020202020202020777261707065722E617070656E6428616374696F6E73293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(783) := '2020636F6D6D656E74577261707065722E617070656E642870726F66696C6550696374757265292E617070656E642874696D65292E617070656E6428636F6D6D656E74486561646572456C292E617070656E642877726170706572293B0A202020202020';
wwv_flow_api.g_varchar2_table(784) := '20202020202072657475726E20636F6D6D656E74577261707065723B0A20202020202020207D2C0A0A20202020202020206372656174655570766F7465456C656D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C29207B0A2020202020';
wwv_flow_api.g_varchar2_table(785) := '202020202020202F2F205570766F74652069636F6E0A202020202020202020202020766172207570766F746549636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7468756D62';
wwv_flow_api.g_varchar2_table(786) := '732D7570270A2020202020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E7570766F746549636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020207570766F746549636F6E';
wwv_flow_api.g_varchar2_table(787) := '2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E7570766F746549636F6E55524C2B27222927293B0A202020202020202020202020202020207570766F746549636F6E2E616464436C61';
wwv_flow_api.g_varchar2_table(788) := '73732827696D61676527293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F205570766F7465730A202020202020202020202020766172207570766F7465456C203D202428273C627574746F6E2F3E272C207B0A2020202020';
wwv_flow_api.g_varchar2_table(789) := '202020202020202020202027636C617373273A2027616374696F6E207570766F746527202B2028636F6D6D656E744D6F64656C2E757365724861735570766F746564203F202720686967686C696768742D666F6E7427203A202727290A20202020202020';
wwv_flow_api.g_varchar2_table(790) := '20202020207D292E617070656E64282428273C7370616E2F3E272C207B0A20202020202020202020202020202020746578743A20636F6D6D656E744D6F64656C2E7570766F7465436F756E742C0A2020202020202020202020202020202027636C617373';
wwv_flow_api.g_varchar2_table(791) := '273A20277570766F74652D636F756E74270A2020202020202020202020207D29292E617070656E64287570766F746549636F6E293B0A0A20202020202020202020202072657475726E207570766F7465456C3B0A20202020202020207D2C0A0A20202020';
wwv_flow_api.g_varchar2_table(792) := '20202020637265617465546167456C656D656E743A2066756E6374696F6E28746578742C206578747261436C61737365732C2076616C75652C2065787472614174747269627574657329207B0A20202020202020202020202076617220746167456C203D';
wwv_flow_api.g_varchar2_table(793) := '202428273C696E7075742F3E272C207B0A2020202020202020202020202020202027636C617373273A2027746167272C0A202020202020202020202020202020202774797065273A2027627574746F6E272C0A2020202020202020202020202020202027';
wwv_flow_api.g_varchar2_table(794) := '646174612D726F6C65273A20276E6F6E65272C0A2020202020202020202020207D293B0A2020202020202020202020206966286578747261436C61737365732920746167456C2E616464436C617373286578747261436C6173736573293B0A2020202020';
wwv_flow_api.g_varchar2_table(795) := '20202020202020746167456C2E76616C2874657874293B0A202020202020202020202020746167456C2E617474722827646174612D76616C7565272C2076616C7565293B0A20202020202020202020202069662028657874726141747472696275746573';
wwv_flow_api.g_varchar2_table(796) := '2920746167456C2E6174747228657874726141747472696275746573293B0A20202020202020202020202072657475726E20746167456C3B0A20202020202020207D2C0A0A20202020202020206372656174654174746163686D656E74546167456C656D';
wwv_flow_api.g_varchar2_table(797) := '656E743A2066756E6374696F6E286174746163686D656E742C2064656C657461626C6529207B0A2020202020202020202020200A2020202020202020202020202F2F2054616720656C656D656E740A202020202020202020202020766172206174746163';
wwv_flow_api.g_varchar2_table(798) := '686D656E74546167203D202428273C612F3E272C207B0A2020202020202020202020202020202027636C617373273A2027746167206174746163686D656E74272C0A2020202020202020202020202020202027746172676574273A20275F626C616E6B27';
wwv_flow_api.g_varchar2_table(799) := '0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20536574206872656620617474726962757465206966206E6F742064656C657461626C650A2020202020202020202020206966282164656C657461626C6529207B0A2020';
wwv_flow_api.g_varchar2_table(800) := '20202020202020202020202020206174746163686D656E745461672E61747472282768726566272C206174746163686D656E742E66696C65293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2042696E6420646174610A20';
wwv_flow_api.g_varchar2_table(801) := '20202020202020202020206174746163686D656E745461672E64617461287B0A2020202020202020202020202020202069643A206174746163686D656E742E69642C0A202020202020202020202020202020206D696D655F747970653A20617474616368';
wwv_flow_api.g_varchar2_table(802) := '6D656E742E6D696D655F747970652C0A2020202020202020202020202020202066696C653A206174746163686D656E742E66696C652C0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2046696C65206E616D650A202020';
wwv_flow_api.g_varchar2_table(803) := '2020202020202020207661722066696C654E616D65203D2027273B0A0A2020202020202020202020202F2F20436173653A2066696C652069732066696C65206F626A6563740A2020202020202020202020206966286174746163686D656E742E66696C65';
wwv_flow_api.g_varchar2_table(804) := '20696E7374616E63656F662046696C6529207B0A2020202020202020202020202020202066696C654E616D65203D206174746163686D656E742E66696C652E6E616D653B0A0A2020202020202020202020202F2F20436173653A2066696C652069732055';
wwv_flow_api.g_varchar2_table(805) := '524C0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020766172207061727473203D206174746163686D656E742E66696C652E73706C697428272F27293B0A2020202020202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(806) := '66696C654E616D65203D2070617274735B70617274732E6C656E677468202D20315D3B0A2020202020202020202020202020202066696C654E616D65203D2066696C654E616D652E73706C697428273F27295B305D3B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(807) := '20202066696C654E616D65203D206465636F6465555249436F6D706F6E656E742866696C654E616D65293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F204174746163686D656E742069636F6E0A20202020202020202020';
wwv_flow_api.g_varchar2_table(808) := '2020766172206174746163686D656E7449636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7061706572636C6970270A2020202020202020202020207D293B0A202020202020';
wwv_flow_api.g_varchar2_table(809) := '202020202020696628746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020206174746163686D656E7449636F6E2E63737328276261636B67726F756E642D696D61';
wwv_flow_api.g_varchar2_table(810) := '6765272C202775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927293B0A202020202020202020202020202020206174746163686D656E7449636F6E2E616464436C6173732827696D61676527293B';
wwv_flow_api.g_varchar2_table(811) := '0A2020202020202020202020207D0A0A2020202020202020202020202F2F20417070656E6420636F6E74656E740A2020202020202020202020206174746163686D656E745461672E617070656E64286174746163686D656E7449636F6E2C2066696C654E';
wwv_flow_api.g_varchar2_table(812) := '616D65293B0A0A2020202020202020202020202F2F204164642064656C65746520627574746F6E2069662064656C657461626C650A20202020202020202020202069662864656C657461626C6529207B0A20202020202020202020202020202020617474';
wwv_flow_api.g_varchar2_table(813) := '6163686D656E745461672E616464436C617373282764656C657461626C6527293B0A0A202020202020202020202020202020202F2F20417070656E6420636C6F736520627574746F6E0A2020202020202020202020202020202076617220636C6F736542';
wwv_flow_api.g_varchar2_table(814) := '7574746F6E203D20746869732E637265617465436C6F7365427574746F6E282764656C65746527293B0A202020202020202020202020202020206174746163686D656E745461672E617070656E6428636C6F7365427574746F6E293B0A20202020202020';
wwv_flow_api.g_varchar2_table(815) := '20202020207D0A0A20202020202020202020202072657475726E206174746163686D656E745461673B0A20202020202020207D2C0A0A2020202020202020726552656E646572436F6D6D656E743A2066756E6374696F6E28696429207B0A202020202020';
wwv_flow_api.g_varchar2_table(816) := '20202020202076617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B69645D3B0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24656C2E66696E6428276C692E';
wwv_flow_api.g_varchar2_table(817) := '636F6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E69642B27225D27293B0A0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020202020636F6D6D656E74456C656D656E74732E';
wwv_flow_api.g_varchar2_table(818) := '656163682866756E6374696F6E28696E6465782C20636F6D6D656E74456C29207B0A2020202020202020202020202020202076617220636F6D6D656E7457726170706572203D2073656C662E637265617465436F6D6D656E7457726170706572456C656D';
wwv_flow_api.g_varchar2_table(819) := '656E7428636F6D6D656E744D6F64656C293B0A202020202020202020202020202020202428636F6D6D656E74456C292E66696E6428272E636F6D6D656E742D7772617070657227292E666972737428292E7265706C6163655769746828636F6D6D656E74';
wwv_flow_api.g_varchar2_table(820) := '57726170706572293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A2020202020202020726552656E646572436F6D6D656E74416374696F6E4261723A2066756E6374696F6E28696429207B0A20202020202020202020202076';
wwv_flow_api.g_varchar2_table(821) := '617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B69645D3B0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24656C2E66696E6428276C692E636F6D6D656E74';
wwv_flow_api.g_varchar2_table(822) := '5B646174612D69643D22272B636F6D6D656E744D6F64656C2E69642B27225D27293B0A2020202020202020202020200A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020202020636F6D6D656E74456C656D';
wwv_flow_api.g_varchar2_table(823) := '656E74732E656163682866756E6374696F6E28696E6465782C20636F6D6D656E74456C29207B0A2020202020202020202020202020202076617220636F6D6D656E7457726170706572203D2073656C662E637265617465436F6D6D656E74577261707065';
wwv_flow_api.g_varchar2_table(824) := '72456C656D656E7428636F6D6D656E744D6F64656C293B0A202020202020202020202020202020202428636F6D6D656E74456C292E66696E6428272E616374696F6E7327292E666972737428292E7265706C6163655769746828636F6D6D656E74577261';
wwv_flow_api.g_varchar2_table(825) := '707065722E66696E6428272E616374696F6E732729293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A2020202020202020726552656E6465725570766F7465733A2066756E6374696F6E28696429207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(826) := '2020202076617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B69645D3B0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24656C2E66696E6428276C692E636F';
wwv_flow_api.g_varchar2_table(827) := '6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E69642B27225D27293B0A0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020202020636F6D6D656E74456C656D656E74732E6561';
wwv_flow_api.g_varchar2_table(828) := '63682866756E6374696F6E28696E6465782C20636F6D6D656E74456C29207B0A20202020202020202020202020202020766172207570766F746573203D2073656C662E6372656174655570766F7465456C656D656E7428636F6D6D656E744D6F64656C29';
wwv_flow_api.g_varchar2_table(829) := '3B0A202020202020202020202020202020202428636F6D6D656E74456C292E66696E6428272E7570766F746527292E666972737428292E7265706C61636557697468287570766F746573293B0A2020202020202020202020207D293B0A20202020202020';
wwv_flow_api.g_varchar2_table(830) := '207D2C0A0A0A20202020202020202F2F205374796C696E670A20202020202020202F2F203D3D3D3D3D3D3D0A0A20202020202020206372656174654373734465636C61726174696F6E733A2066756E6374696F6E2829207B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(831) := '20202F2F2052656D6F76652070726576696F7573206373732D6465636C61726174696F6E730A20202020202020202020202024282768656164207374796C652E6A71756572792D636F6D6D656E74732D63737327292E72656D6F766528293B0A0A202020';
wwv_flow_api.g_varchar2_table(832) := '2020202020202020202F2F204E617669676174696F6E20756E6465726C696E650A202020202020202020202020746869732E63726561746543737328272E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C692E6163746976';
wwv_flow_api.g_varchar2_table(833) := '653A6166746572207B6261636B67726F756E643A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F7220202B20272021696D706F7274616E743B272C0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(834) := '202020202B277D27293B0A0A2020202020202020202020202F2F2044726F70646F776E2061637469766520656C656D656E740A202020202020202020202020746869732E63726561746543737328272E6A71756572792D636F6D6D656E747320756C2E6E';
wwv_flow_api.g_varchar2_table(835) := '617669676174696F6E20756C2E64726F70646F776E206C692E616374697665207B6261636B67726F756E643A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F7220202B2027202169';
wwv_flow_api.g_varchar2_table(836) := '6D706F7274616E743B272C0A202020202020202020202020202020202B277D27293B0A0A2020202020202020202020202F2F204261636B67726F756E6420686967686C696768740A202020202020202020202020746869732E6372656174654373732827';
wwv_flow_api.g_varchar2_table(837) := '2E6A71756572792D636F6D6D656E7473202E686967686C696768742D6261636B67726F756E64207B6261636B67726F756E643A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F7220';
wwv_flow_api.g_varchar2_table(838) := '202B20272021696D706F7274616E743B272C0A202020202020202020202020202020202B277D27293B0A0A2020202020202020202020202F2F20466F6E7420686967686C696768740A202020202020202020202020746869732E63726561746543737328';
wwv_flow_api.g_varchar2_table(839) := '272E6A71756572792D636F6D6D656E7473202E686967686C696768742D666F6E74207B636F6C6F723A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F72202B20272021696D706F72';
wwv_flow_api.g_varchar2_table(840) := '74616E743B270A202020202020202020202020202020202B277D27293B0A202020202020202020202020746869732E63726561746543737328272E6A71756572792D636F6D6D656E7473202E686967686C696768742D666F6E742D626F6C64207B636F6C';
wwv_flow_api.g_varchar2_table(841) := '6F723A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F72202B20272021696D706F7274616E743B270A202020202020202020202020202020202B2027666F6E742D7765696768743A';
wwv_flow_api.g_varchar2_table(842) := '20626F6C643B270A202020202020202020202020202020202B277D27293B0A20202020202020207D2C0A0A20202020202020206372656174654373733A2066756E6374696F6E2863737329207B0A202020202020202020202020766172207374796C6545';
wwv_flow_api.g_varchar2_table(843) := '6C203D202428273C7374796C652F3E272C207B0A20202020202020202020202020202020747970653A2027746578742F637373272C0A2020202020202020202020202020202027636C617373273A20276A71756572792D636F6D6D656E74732D63737327';
wwv_flow_api.g_varchar2_table(844) := '2C0A20202020202020202020202020202020746578743A206373730A2020202020202020202020207D293B0A2020202020202020202020202428276865616427292E617070656E64287374796C65456C293B0A20202020202020207D2C0A0A0A20202020';
wwv_flow_api.g_varchar2_table(845) := '202020202F2F205574696C69746965730A20202020202020202F2F203D3D3D3D3D3D3D3D3D0A0A2020202020202020676574436F6D6D656E74733A2066756E6374696F6E2829207B0A2020202020202020202020207661722073656C66203D2074686973';
wwv_flow_api.g_varchar2_table(846) := '3B0A20202020202020202020202072657475726E204F626A6563742E6B65797328746869732E636F6D6D656E747342794964292E6D61702866756E6374696F6E286964297B72657475726E2073656C662E636F6D6D656E7473427949645B69645D7D293B';
wwv_flow_api.g_varchar2_table(847) := '0A20202020202020207D2C0A0A20202020202020206765744368696C64436F6D6D656E74733A2066756E6374696F6E28706172656E74496429207B0A20202020202020202020202072657475726E20746869732E676574436F6D6D656E747328292E6669';
wwv_flow_api.g_varchar2_table(848) := '6C7465722866756E6374696F6E28636F6D6D656E74297B72657475726E20636F6D6D656E742E706172656E74203D3D20706172656E7449647D293B0A20202020202020207D2C0A0A20202020202020206765744174746163686D656E74733A2066756E63';
wwv_flow_api.g_varchar2_table(849) := '74696F6E2829207B0A20202020202020202020202072657475726E20746869732E676574436F6D6D656E747328292E66696C7465722866756E6374696F6E28636F6D6D656E74297B72657475726E20636F6D6D656E742E6861734174746163686D656E74';
wwv_flow_api.g_varchar2_table(850) := '7328297D293B0A20202020202020207D2C0A0A20202020202020206765744F757465726D6F7374506172656E743A2066756E6374696F6E28646972656374506172656E74496429207B0A20202020202020202020202076617220706172656E744964203D';
wwv_flow_api.g_varchar2_table(851) := '20646972656374506172656E7449643B0A202020202020202020202020646F207B0A2020202020202020202020202020202076617220706172656E74436F6D6D656E74203D20746869732E636F6D6D656E7473427949645B706172656E7449645D3B0A20';
wwv_flow_api.g_varchar2_table(852) := '202020202020202020202020202020706172656E744964203D20706172656E74436F6D6D656E742E706172656E743B0A2020202020202020202020207D207768696C6528706172656E74436F6D6D656E742E706172656E7420213D206E756C6C293B0A20';
wwv_flow_api.g_varchar2_table(853) := '202020202020202020202072657475726E20706172656E74436F6D6D656E743B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E744A534F4E3A2066756E6374696F6E28636F6D6D656E74696E674669656C6429207B0A';
wwv_flow_api.g_varchar2_table(854) := '202020202020202020202020766172207465787461726561203D20636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127293B0A2020202020202020202020207661722074696D65203D206E6577204461746528292E746F4953';
wwv_flow_api.g_varchar2_table(855) := '4F537472696E6728293B0A0A20202020202020202020202076617220636F6D6D656E744A534F4E203D207B0A2020202020202020202020202020202069643A20276327202B202028746869732E676574436F6D6D656E747328292E6C656E677468202B20';
wwv_flow_api.g_varchar2_table(856) := '31292C2020202F2F2054656D706F726172792069640A20202020202020202020202020202020706172656E743A2074657874617265612E617474722827646174612D706172656E742729207C7C206E756C6C2C0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(857) := '637265617465643A2074696D652C0A202020202020202020202020202020206D6F6469666965643A2074696D652C0A20202020202020202020202020202020636F6E74656E743A20746869732E6765745465787461726561436F6E74656E742874657874';
wwv_flow_api.g_varchar2_table(858) := '61726561292C0A2020202020202020202020202020202070696E67733A20746869732E67657450696E6773287465787461726561292C0A2020202020202020202020202020202066756C6C6E616D653A20746869732E6F7074696F6E732E74657874466F';
wwv_flow_api.g_varchar2_table(859) := '726D617474657228746869732E6F7074696F6E732E796F7554657874292C0A2020202020202020202020202020202070726F66696C655069637475726555524C3A20746869732E6F7074696F6E732E70726F66696C655069637475726555524C2C0A2020';
wwv_flow_api.g_varchar2_table(860) := '202020202020202020202020202063726561746564427943757272656E74557365723A20747275652C0A202020202020202020202020202020207570766F7465436F756E743A20302C0A2020202020202020202020202020202075736572486173557076';
wwv_flow_api.g_varchar2_table(861) := '6F7465643A2066616C73652C0A202020202020202020202020202020206174746163686D656E74733A20746869732E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C6428636F6D6D656E74696E674669656C64290A2020';
wwv_flow_api.g_varchar2_table(862) := '202020202020202020207D3B0A20202020202020202020202072657475726E20636F6D6D656E744A534F4E3B0A20202020202020207D2C0A0A20202020202020206973416C6C6F776564546F44656C6574653A2066756E6374696F6E28636F6D6D656E74';
wwv_flow_api.g_varchar2_table(863) := '496429207B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C6544656C6574696E6729207B0A20202020202020202020202020202020766172206973416C6C6F776564546F44656C657465203D20747275653B0A2020';
wwv_flow_api.g_varchar2_table(864) := '202020202020202020202020202069662821746869732E6F7074696F6E732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C69657329207B0A20202020202020202020202020202020202020202428746869732E676574436F6D';
wwv_flow_api.g_varchar2_table(865) := '6D656E74732829292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E7429207B0A202020202020202020202020202020202020202020202020696628636F6D6D656E742E706172656E74203D3D20636F6D6D656E7449642920697341';
wwv_flow_api.g_varchar2_table(866) := '6C6C6F776564546F44656C657465203D2066616C73653B0A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020207D0A2020202020202020202020202020202072657475726E206973416C6C6F776564546F';
wwv_flow_api.g_varchar2_table(867) := '44656C6574653B0A2020202020202020202020207D0A20202020202020202020202072657475726E2066616C73653B0A20202020202020207D2C0A0A2020202020202020736574546F67676C65416C6C427574746F6E546578743A2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(868) := '28746F67676C65416C6C427574746F6E2C20746F67676C6529207B0A2020202020202020202020207661722073656C66203D20746869733B0A2020202020202020202020207661722074657874436F6E7461696E6572203D20746F67676C65416C6C4275';
wwv_flow_api.g_varchar2_table(869) := '74746F6E2E66696E6428277370616E2E7465787427293B0A202020202020202020202020766172206361726574203D20746F67676C65416C6C427574746F6E2E66696E6428272E636172657427293B0A0A2020202020202020202020207661722073686F';
wwv_flow_api.g_varchar2_table(870) := '77457870616E64696E6754657874203D2066756E6374696F6E2829207B0A202020202020202020202020202020207661722074657874203D2073656C662E6F7074696F6E732E74657874466F726D61747465722873656C662E6F7074696F6E732E766965';
wwv_flow_api.g_varchar2_table(871) := '77416C6C5265706C69657354657874293B0A20202020202020202020202020202020766172207265706C79436F756E74203D20746F67676C65416C6C427574746F6E2E7369626C696E677328272E636F6D6D656E7427292E6E6F7428272E68696464656E';
wwv_flow_api.g_varchar2_table(872) := '27292E6C656E6774683B0A2020202020202020202020202020202074657874203D20746578742E7265706C61636528275F5F7265706C79436F756E745F5F272C207265706C79436F756E74293B0A2020202020202020202020202020202074657874436F';
wwv_flow_api.g_varchar2_table(873) := '6E7461696E65722E746578742874657874293B0A2020202020202020202020207D3B0A0A20202020202020202020202076617220686964655265706C69657354657874203D20746869732E6F7074696F6E732E74657874466F726D617474657228746869';
wwv_flow_api.g_varchar2_table(874) := '732E6F7074696F6E732E686964655265706C69657354657874293B0A0A202020202020202020202020696628746F67676C6529207B0A0A202020202020202020202020202020202F2F20546F67676C6520746578740A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(875) := '202069662874657874436F6E7461696E65722E746578742829203D3D20686964655265706C6965735465787429207B0A202020202020202020202020202020202020202073686F77457870616E64696E675465787428293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(876) := '20202020207D20656C7365207B0A202020202020202020202020202020202020202074657874436F6E7461696E65722E7465787428686964655265706C69657354657874293B0A202020202020202020202020202020207D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(877) := '20202020202F2F20546F67676C6520646972656374696F6E206F66207468652063617265740A2020202020202020202020202020202063617265742E746F67676C65436C6173732827757027293B0A0A2020202020202020202020207D20656C7365207B';
wwv_flow_api.g_varchar2_table(878) := '0A0A202020202020202020202020202020202F2F205570646174652074657874206966206E65636573736172790A2020202020202020202020202020202069662874657874436F6E7461696E65722E74657874282920213D20686964655265706C696573';
wwv_flow_api.g_varchar2_table(879) := '5465787429207B0A202020202020202020202020202020202020202073686F77457870616E64696E675465787428293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020';
wwv_flow_api.g_varchar2_table(880) := '20736574427574746F6E53746174653A2066756E6374696F6E28627574746F6E2C20656E61626C65642C206C6F6164696E6729207B0A202020202020202020202020627574746F6E2E746F67676C65436C6173732827656E61626C6564272C20656E6162';
wwv_flow_api.g_varchar2_table(881) := '6C6564293B0A2020202020202020202020206966286C6F6164696E6729207B0A20202020202020202020202020202020627574746F6E2E68746D6C28746869732E6372656174655370696E6E6572287472756529293B0A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(882) := '20656C7365207B0A20202020202020202020202020202020627574746F6E2E68746D6C28627574746F6E2E6461746128276F726967696E616C2D636F6E74656E742729293B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020';
wwv_flow_api.g_varchar2_table(883) := '2020202061646A75737454657874617265614865696768743A2066756E6374696F6E2874657874617265612C20666F63757329207B0A20202020202020202020202076617220746578746172656142617365486569676874203D20322E323B0A20202020';
wwv_flow_api.g_varchar2_table(884) := '2020202020202020766172206C696E65486569676874203D20312E34353B0A0A20202020202020202020202076617220736574526F7773203D2066756E6374696F6E28726F777329207B0A20202020202020202020202020202020766172206865696768';
wwv_flow_api.g_varchar2_table(885) := '74203D20746578746172656142617365486569676874202B2028726F7773202D203129202A206C696E654865696768743B0A2020202020202020202020202020202074657874617265612E6373732827686569676874272C20686569676874202B202765';
wwv_flow_api.g_varchar2_table(886) := '6D27293B0A2020202020202020202020207D3B0A0A2020202020202020202020207465787461726561203D2024287465787461726561293B0A20202020202020202020202076617220726F77436F756E74203D20666F637573203D3D2074727565203F20';
wwv_flow_api.g_varchar2_table(887) := '746869732E6F7074696F6E732E7465787461726561526F77734F6E466F637573203A20746869732E6F7074696F6E732E7465787461726561526F77733B0A202020202020202020202020646F207B0A20202020202020202020202020202020736574526F';
wwv_flow_api.g_varchar2_table(888) := '777328726F77436F756E74293B0A20202020202020202020202020202020726F77436F756E742B2B3B0A20202020202020202020202020202020766172206973417265615363726F6C6C61626C65203D2074657874617265615B305D2E7363726F6C6C48';
wwv_flow_api.g_varchar2_table(889) := '6569676874203E2074657874617265612E6F7574657248656967687428293B0A20202020202020202020202020202020766172206D6178526F777355736564203D20746869732E6F7074696F6E732E74657874617265614D6178526F7773203D3D206661';
wwv_flow_api.g_varchar2_table(890) := '6C7365203F0A202020202020202020202020202020202020202066616C7365203A20726F77436F756E74203E20746869732E6F7074696F6E732E74657874617265614D6178526F77733B0A2020202020202020202020207D207768696C65286973417265';
wwv_flow_api.g_varchar2_table(891) := '615363726F6C6C61626C6520262620216D6178526F777355736564293B0A20202020202020207D2C0A0A2020202020202020636C65617254657874617265613A2066756E6374696F6E28746578746172656129207B0A2020202020202020202020207465';
wwv_flow_api.g_varchar2_table(892) := '7874617265612E656D70747928292E747269676765722827696E70757427293B0A20202020202020207D2C0A0A20202020202020206765745465787461726561436F6E74656E743A2066756E6374696F6E2874657874617265612C2068756D616E526561';
wwv_flow_api.g_varchar2_table(893) := '6461626C6529207B0A202020202020202020202020766172207465787461726561436C6F6E65203D2074657874617265612E636C6F6E6528293B0A0A2020202020202020202020202F2F2052656D6F7665207265706C792D746F207461670A2020202020';
wwv_flow_api.g_varchar2_table(894) := '202020202020207465787461726561436C6F6E652E66696E6428272E7265706C792D746F2E74616727292E72656D6F766528293B0A0A2020202020202020202020202F2F205265706C6163652074616773207769746820746578742076616C7565730A20';
wwv_flow_api.g_varchar2_table(895) := '20202020202020202020207465787461726561436C6F6E652E66696E6428272E7461672E6861736874616727292E7265706C616365576974682866756E6374696F6E28297B0A2020202020202020202020202020202072657475726E2068756D616E5265';
wwv_flow_api.g_varchar2_table(896) := '616461626C65203F20242874686973292E76616C2829203A20272327202B20242874686973292E617474722827646174612D76616C756527293B0A2020202020202020202020207D293B0A2020202020202020202020207465787461726561436C6F6E65';
wwv_flow_api.g_varchar2_table(897) := '2E66696E6428272E7461672E70696E6727292E7265706C616365576974682866756E6374696F6E28297B0A2020202020202020202020202020202072657475726E2068756D616E5265616461626C65203F20242874686973292E76616C2829203A202740';
wwv_flow_api.g_varchar2_table(898) := '27202B20242874686973292E617474722827646174612D76616C756527293B0A2020202020202020202020207D293B0A0A202020202020202020202020766172206365203D202428273C7072652F3E27292E68746D6C287465787461726561436C6F6E65';
wwv_flow_api.g_varchar2_table(899) := '2E68746D6C2829293B0A20202020202020202020202063652E66696E6428276469762C20702C20627227292E7265706C616365576974682866756E6374696F6E2829207B2072657475726E20275C6E27202B20746869732E696E6E657248544D4C3B207D';
wwv_flow_api.g_varchar2_table(900) := '293B0A0A2020202020202020202020202F2F205472696D206C656164696E67207370616365730A2020202020202020202020207661722074657874203D2063652E7465787428292E7265706C616365282F5E5C732B2F672C202727293B0A0A2020202020';
wwv_flow_api.g_varchar2_table(901) := '202020202020202F2F204E6F726D616C697A65207370616365730A2020202020202020202020207661722074657874203D20746869732E6E6F726D616C697A655370616365732874657874293B0A20202020202020202020202072657475726E20746578';
wwv_flow_api.g_varchar2_table(902) := '743B0A20202020202020207D2C0A0A2020202020202020676574466F726D6174746564436F6D6D656E74436F6E74656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2C207265706C6163654E65774C696E657329207B0A20202020202020';
wwv_flow_api.g_varchar2_table(903) := '20202020207661722068746D6C203D20746869732E65736361706528636F6D6D656E744D6F64656C2E636F6E74656E74293B0A20202020202020202020202068746D6C203D20746869732E6C696E6B6966792868746D6C293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(904) := '202068746D6C203D20746869732E686967686C696768745461677328636F6D6D656E744D6F64656C2C2068746D6C293B0A2020202020202020202020206966287265706C6163654E65774C696E6573292068746D6C203D2068746D6C2E7265706C616365';
wwv_flow_api.g_varchar2_table(905) := '282F283F3A5C6E292F672C20273C62723E27293B0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A20202020202020202F2F2052657475726E2070696E677320696E20666F726D61740A2020202020202020';
wwv_flow_api.g_varchar2_table(906) := '2F2F20207B0A20202020202020202F2F2020202020206964313A207573657246756C6C6E616D65312C0A20202020202020202F2F2020202020206964323A207573657246756C6C6E616D65322C0A20202020202020202F2F2020202020202E2E2E0A2020';
wwv_flow_api.g_varchar2_table(907) := '2020202020202F2F20207D0A202020202020202067657450696E67733A2066756E6374696F6E28746578746172656129207B0A2020202020202020202020207661722070696E6773203D207B7D3B0A20202020202020202020202074657874617265612E';
wwv_flow_api.g_varchar2_table(908) := '66696E6428272E70696E6727292E656163682866756E6374696F6E28696E6465782C20656C297B0A20202020202020202020202020202020766172206964203D207061727365496E74282428656C292E617474722827646174612D76616C75652729293B';
wwv_flow_api.g_varchar2_table(909) := '0A202020202020202020202020202020207661722076616C7565203D202428656C292E76616C28293B0A2020202020202020202020202020202070696E67735B69645D203D2076616C75652E736C6963652831293B0A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(910) := '3B0A20202020202020202020202072657475726E2070696E67733B0A20202020202020207D2C0A0A20202020202020206765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C643A2066756E6374696F6E28636F6D6D656E7469';
wwv_flow_api.g_varchar2_table(911) := '6E674669656C6429207B0A202020202020202020202020766172206174746163686D656E7473203D20636F6D6D656E74696E674669656C642E66696E6428272E6174746163686D656E7473202E6174746163686D656E7427292E6D61702866756E637469';
wwv_flow_api.g_varchar2_table(912) := '6F6E28297B0A2020202020202020202020202020202072657475726E20242874686973292E6461746128293B0A2020202020202020202020207D292E746F417272617928293B0A0A20202020202020202020202072657475726E206174746163686D656E';
wwv_flow_api.g_varchar2_table(913) := '74733B0A20202020202020207D2C0A0A20202020202020206D6F7665437572736F72546F456E643A2066756E6374696F6E28656C29207B0A202020202020202020202020656C203D202428656C295B305D3B0A0A2020202020202020202020202F2F2054';
wwv_flow_api.g_varchar2_table(914) := '72696767657220696E70757420746F2061646A7573742073697A650A2020202020202020202020202428656C292E747269676765722827696E70757427293B0A0A2020202020202020202020202F2F205363726F6C6C20746F20626F74746F6D0A202020';
wwv_flow_api.g_varchar2_table(915) := '2020202020202020202428656C292E7363726F6C6C546F7028656C2E7363726F6C6C486569676874293B0A0A2020202020202020202020202F2F204D6F766520637572736F7220746F20656E640A20202020202020202020202069662028747970656F66';
wwv_flow_api.g_varchar2_table(916) := '2077696E646F772E67657453656C656374696F6E20213D2027756E646566696E65642720262620747970656F6620646F63756D656E742E63726561746552616E676520213D2027756E646566696E65642729207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(917) := '207661722072616E6765203D20646F63756D656E742E63726561746552616E676528293B0A2020202020202020202020202020202072616E67652E73656C6563744E6F6465436F6E74656E747328656C293B0A2020202020202020202020202020202072';
wwv_flow_api.g_varchar2_table(918) := '616E67652E636F6C6C617073652866616C7365293B0A202020202020202020202020202020207661722073656C203D2077696E646F772E67657453656C656374696F6E28293B0A2020202020202020202020202020202073656C2E72656D6F7665416C6C';
wwv_flow_api.g_varchar2_table(919) := '52616E67657328293B0A2020202020202020202020202020202073656C2E61646452616E67652872616E6765293B0A2020202020202020202020207D20656C73652069662028747970656F6620646F63756D656E742E626F64792E637265617465546578';
wwv_flow_api.g_varchar2_table(920) := '7452616E676520213D2027756E646566696E65642729207B0A20202020202020202020202020202020766172207465787452616E6765203D20646F63756D656E742E626F64792E6372656174655465787452616E676528293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(921) := '2020202020207465787452616E67652E6D6F7665546F456C656D656E745465787428656C293B0A202020202020202020202020202020207465787452616E67652E636F6C6C617073652866616C7365293B0A202020202020202020202020202020207465';
wwv_flow_api.g_varchar2_table(922) := '787452616E67652E73656C65637428293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20466F6375730A202020202020202020202020656C2E666F63757328293B0A20202020202020207D2C0A0A2020202020202020656E';
wwv_flow_api.g_varchar2_table(923) := '73757265456C656D656E74537461797356697369626C653A2066756E6374696F6E28656C29207B0A202020202020202020202020766172206D61785363726F6C6C546F70203D20656C2E706F736974696F6E28292E746F703B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(924) := '2020766172206D696E5363726F6C6C546F70203D20656C2E706F736974696F6E28292E746F70202B20656C2E6F757465724865696768742829202D20746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E6F75746572486569676874';
wwv_flow_api.g_varchar2_table(925) := '28293B0A0A2020202020202020202020202F2F20436173653A20656C656D656E742068696464656E2061626F76652073636F6C6C20617265610A202020202020202020202020696628746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65';
wwv_flow_api.g_varchar2_table(926) := '722E7363726F6C6C546F702829203E206D61785363726F6C6C546F7029207B0A20202020202020202020202020202020746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F70286D61785363726F6C6C546F7029';
wwv_flow_api.g_varchar2_table(927) := '3B0A0A2020202020202020202020202F2F20436173653A20656C656D656E742068696464656E2062656C6F772073636F6C6C20617265610A2020202020202020202020207D20656C736520696628746869732E6F7074696F6E732E7363726F6C6C436F6E';
wwv_flow_api.g_varchar2_table(928) := '7461696E65722E7363726F6C6C546F702829203C206D696E5363726F6C6C546F7029207B0A20202020202020202020202020202020746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F70286D696E5363726F6C';
wwv_flow_api.g_varchar2_table(929) := '6C546F70293B0A2020202020202020202020207D0A0A20202020202020207D2C0A0A20202020202020206573636170653A2066756E6374696F6E28696E7075745465787429207B0A20202020202020202020202072657475726E202428273C7072652F3E';
wwv_flow_api.g_varchar2_table(930) := '27292E7465787428746869732E6E6F726D616C697A6553706163657328696E7075745465787429292E68746D6C28293B0A20202020202020207D2C0A0A20202020202020206E6F726D616C697A655370616365733A2066756E6374696F6E28696E707574';
wwv_flow_api.g_varchar2_table(931) := '5465787429207B0A20202020202020202020202072657475726E20696E707574546578742E7265706C616365286E65772052656745787028275C7530306130272C20276727292C20272027293B2020202F2F20436F6E76657274206E6F6E2D627265616B';
wwv_flow_api.g_varchar2_table(932) := '696E672073706163657320746F20726567756172207370616365730A20202020202020207D2C0A0A202020202020202061667465723A2066756E6374696F6E2874696D65732C2066756E6329207B0A2020202020202020202020207661722073656C6620';
wwv_flow_api.g_varchar2_table(933) := '3D20746869733B0A20202020202020202020202072657475726E2066756E6374696F6E2829207B0A2020202020202020202020202020202074696D65732D2D3B0A202020202020202020202020202020206966202874696D6573203D3D203029207B0A20';
wwv_flow_api.g_varchar2_table(934) := '2020202020202020202020202020202020202072657475726E2066756E632E6170706C792873656C662C20617267756D656E7473293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A20';
wwv_flow_api.g_varchar2_table(935) := '20202020202020686967686C69676874546167733A2066756E6374696F6E28636F6D6D656E744D6F64656C2C2068746D6C29207B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654861736874616773292068746D';
wwv_flow_api.g_varchar2_table(936) := '6C203D20746869732E686967686C69676874486173687461677328636F6D6D656E744D6F64656C2C2068746D6C293B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C6550696E67696E67292068746D6C203D207468';
wwv_flow_api.g_varchar2_table(937) := '69732E686967686C6967687450696E677328636F6D6D656E744D6F64656C2C2068746D6C293B0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A2020202020202020686967686C6967687448617368746167';
wwv_flow_api.g_varchar2_table(938) := '733A2066756E6374696F6E28636F6D6D656E744D6F64656C2C2068746D6C29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202069662868746D6C2E696E6465784F66282723272920213D20';
wwv_flow_api.g_varchar2_table(939) := '2D3129207B0A0A20202020202020202020202020202020766172205F5F637265617465546167203D2066756E6374696F6E2874616729207B0A202020202020202020202020202020202020202076617220746167203D2073656C662E6372656174655461';
wwv_flow_api.g_varchar2_table(940) := '67456C656D656E7428272327202B207461672C202768617368746167272C20746167293B0A202020202020202020202020202020202020202072657475726E207461675B305D2E6F7574657248544D4C3B0A202020202020202020202020202020207D0A';
wwv_flow_api.g_varchar2_table(941) := '0A20202020202020202020202020202020766172207265676578203D202F285E7C5C732923285B612D7A5C75303043302D5C75303046465C642D5F5D2B292F67696D3B0A2020202020202020202020202020202068746D6C203D2068746D6C2E7265706C';
wwv_flow_api.g_varchar2_table(942) := '6163652872656765782C2066756E6374696F6E2824302C2024312C202432297B0A202020202020202020202020202020202020202072657475726E202431202B205F5F637265617465546167282432293B0A202020202020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(943) := '3B0A2020202020202020202020207D0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A2020202020202020686967686C6967687450696E67733A2066756E6374696F6E28636F6D6D656E744D6F64656C2C20';
wwv_flow_api.g_varchar2_table(944) := '68746D6C29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202069662868746D6C2E696E6465784F66282740272920213D202D3129207B0A0A20202020202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(945) := '205F5F637265617465546167203D2066756E6374696F6E2870696E67546578742C2075736572496429207B0A202020202020202020202020202020202020202076617220746167203D2073656C662E637265617465546167456C656D656E742870696E67';
wwv_flow_api.g_varchar2_table(946) := '546578742C202770696E67272C207573657249642C207B0A20202020202020202020202020202020202020202020202027646174612D757365722D6964273A207573657249640A20202020202020202020202020202020202020207D293B0A0A20202020';
wwv_flow_api.g_varchar2_table(947) := '2020202020202020202020202020202072657475726E207461675B305D2E6F7574657248544D4C3B0A202020202020202020202020202020207D0A0A2020202020202020202020202020202024284F626A6563742E6B65797328636F6D6D656E744D6F64';
wwv_flow_api.g_varchar2_table(948) := '656C2E70696E677329292E656163682866756E6374696F6E28696E6465782C2075736572496429207B0A20202020202020202020202020202020202020207661722066756C6C6E616D65203D20636F6D6D656E744D6F64656C2E70696E67735B75736572';
wwv_flow_api.g_varchar2_table(949) := '49645D3B0A20202020202020202020202020202020202020207661722070696E6754657874203D20274027202B2066756C6C6E616D653B0A20202020202020202020202020202020202020200A20202020202020202020202020202020202020202F2F4D';
wwv_flow_api.g_varchar2_table(950) := '4F444946494544205249434841524442414C444F4749202020200A202020202020202020202020202020202020202068746D6C203D2068746D6C2E7265706C61636528274027202B207573657249642C205F5F6372656174655461672870696E67546578';
wwv_flow_api.g_varchar2_table(951) := '742C2075736572496429293B0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A20202020202020206C696E6B6966793A';
wwv_flow_api.g_varchar2_table(952) := '2066756E6374696F6E28696E7075745465787429207B0A202020202020202020202020766172207265706C61636564546578742C207265706C6163655061747465726E312C207265706C6163655061747465726E322C207265706C616365506174746572';
wwv_flow_api.g_varchar2_table(953) := '6E333B0A0A2020202020202020202020202F2F2055524C73207374617274696E67207769746820687474703A2F2F2C2068747470733A2F2F2C206674703A2F2F206F722066696C653A2F2F0A2020202020202020202020207265706C6163655061747465';
wwv_flow_api.g_varchar2_table(954) := '726E31203D202F285C622868747470733F7C6674707C66696C65293A5C2F5C2F5B2D412D5AC384C396C385302D392B2640235C2F253F3D7E5F7C213A2C2E3B7B7D5D2A5B2D412D5AC384C396C385302D392B2640235C2F253D7E5F7C7B7D5D292F67696D';
wwv_flow_api.g_varchar2_table(955) := '3B0A2020202020202020202020207265706C6163656454657874203D20696E707574546578742E7265706C616365287265706C6163655061747465726E312C20273C6120687265663D22243122207461726765743D225F626C616E6B223E24313C2F613E';
wwv_flow_api.g_varchar2_table(956) := '27293B0A0A2020202020202020202020202F2F2055524C73207374617274696E67207769746820227777772E222028776974686F7574202F2F206265666F72652069742C206F7220697420776F756C642072652D6C696E6B20746865206F6E657320646F';
wwv_flow_api.g_varchar2_table(957) := '6E652061626F7665292E0A2020202020202020202020207265706C6163655061747465726E32203D202F285E7C5B5E5C2F665D29287777775C2E5B2D412D5AC384C396C385302D392B2640235C2F253F3D7E5F7C213A2C2E3B7B7D5D2A5B2D412D5AC384';
wwv_flow_api.g_varchar2_table(958) := 'C396C385302D392B2640235C2F253D7E5F7C7B7D5D292F67696D3B0A2020202020202020202020207265706C6163656454657874203D207265706C61636564546578742E7265706C616365287265706C6163655061747465726E322C202724313C612068';
wwv_flow_api.g_varchar2_table(959) := '7265663D2268747470733A2F2F243222207461726765743D225F626C616E6B223E24323C2F613E27293B0A0A2020202020202020202020202F2F204368616E676520656D61696C2061646472657373657320746F206D61696C746F3A206C696E6B732E0A';
wwv_flow_api.g_varchar2_table(960) := '2020202020202020202020207265706C6163655061747465726E33203D202F28285B412D5AC384C396C385302D395C2D5C5F5C2E5D292B405B412D5AC384C396C3855C5F5D2B3F285C2E5B412D5AC384C396C3855D7B322C367D292B292F67696D3B0A20';
wwv_flow_api.g_varchar2_table(961) := '20202020202020202020207265706C6163656454657874203D207265706C61636564546578742E7265706C616365287265706C6163655061747465726E332C20273C6120687265663D226D61696C746F3A243122207461726765743D225F626C616E6B22';
wwv_flow_api.g_varchar2_table(962) := '3E24313C2F613E27293B0A0A2020202020202020202020202F2F2049662074686572652061726520687265667320696E20746865206F726967696E616C20746578742C206C657427732073706C69740A2020202020202020202020202F2F207468652074';
wwv_flow_api.g_varchar2_table(963) := '65787420757020616E64206F6E6C7920776F726B206F6E20746865207061727473207468617420646F6E277420686176652075726C73207965742E0A20202020202020202020202076617220636F756E74203D20696E707574546578742E6D6174636828';
wwv_flow_api.g_varchar2_table(964) := '2F3C6120687265662F6729207C7C205B5D3B0A0A20202020202020202020202069662028636F756E742E6C656E677468203E203029207B0A202020202020202020202020202020202F2F204B6565702064656C696D69746572207768656E2073706C6974';
wwv_flow_api.g_varchar2_table(965) := '74696E670A202020202020202020202020202020207661722073706C6974496E707574203D20696E707574546578742E73706C6974282F283C5C2F613E292F67293B0A20202020202020202020202020202020666F7220287661722069203D2030203B20';
wwv_flow_api.g_varchar2_table(966) := '69203C2073706C6974496E7075742E6C656E677468203B20692B2B29207B0A20202020202020202020202020202020202020206966202873706C6974496E7075745B695D2E6D61746368282F3C6120687265662F6729203D3D206E756C6C29207B0A2020';
wwv_flow_api.g_varchar2_table(967) := '2020202020202020202020202020202020202020202073706C6974496E7075745B695D203D2073706C6974496E7075745B695D0A202020202020202020202020202020202020202020202020202020202E7265706C616365287265706C61636550617474';
wwv_flow_api.g_varchar2_table(968) := '65726E312C20273C6120687265663D22243122207461726765743D225F626C616E6B223E24313C2F613E27290A202020202020202020202020202020202020202020202020202020202E7265706C616365287265706C6163655061747465726E322C2027';
wwv_flow_api.g_varchar2_table(969) := '24313C6120687265663D2268747470733A2F2F243222207461726765743D225F626C616E6B223E24323C2F613E27290A202020202020202020202020202020202020202020202020202020202E7265706C616365287265706C6163655061747465726E33';
wwv_flow_api.g_varchar2_table(970) := '2C20273C6120687265663D226D61696C746F3A243122207461726765743D225F626C616E6B223E24313C2F613E27293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(971) := '202020202076617220636F6D62696E65645265706C6163656454657874203D2073706C6974496E7075742E6A6F696E282727293B0A2020202020202020202020202020202072657475726E20636F6D62696E65645265706C61636564546578743B0A2020';
wwv_flow_api.g_varchar2_table(972) := '202020202020202020207D20656C7365207B0A2020202020202020202020202020202072657475726E207265706C61636564546578743B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202077616974556E74696C3A';
wwv_flow_api.g_varchar2_table(973) := '2066756E6374696F6E28636F6E646974696F6E2C2063616C6C6261636B29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A202020202020202020202020696628636F6E646974696F6E282929207B0A20202020202020';
wwv_flow_api.g_varchar2_table(974) := '20202020202020202063616C6C6261636B28293B0A2020202020202020202020207D20656C7365207B0A2020202020202020202020202020202073657454696D656F75742866756E6374696F6E2829207B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(975) := '202073656C662E77616974556E74696C28636F6E646974696F6E2C2063616C6C6261636B293B0A202020202020202020202020202020207D2C20313030293B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020206172';
wwv_flow_api.g_varchar2_table(976) := '65417272617973457175616C3A2066756E6374696F6E286172726179312C2061727261793229207B0A0A2020202020202020202020202F2F20436173653A206172726179732061726520646966666572656E742073697A65640A20202020202020202020';
wwv_flow_api.g_varchar2_table(977) := '20206966286172726179312E6C656E67746820213D206172726179322E6C656E67746829207B0A2020202020202020202020202020202072657475726E2066616C73653B0A0A2020202020202020202020202F2F20436173653A20617272617973206172';
wwv_flow_api.g_varchar2_table(978) := '6520657175616C2073697A65640A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020206172726179312E736F727428293B0A202020202020202020202020202020206172726179322E736F727428293B0A0A2020';
wwv_flow_api.g_varchar2_table(979) := '2020202020202020202020202020666F722876617220693D303B2069203C206172726179312E6C656E6774683B20692B2B29207B0A20202020202020202020202020202020202020206966286172726179315B695D20213D206172726179325B695D2920';
wwv_flow_api.g_varchar2_table(980) := '72657475726E2066616C73653B0A202020202020202020202020202020207D0A0A2020202020202020202020202020202072657475726E20747275653B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020206170706C';
wwv_flow_api.g_varchar2_table(981) := '79496E7465726E616C4D617070696E67733A2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A2020202020202020202020202F2F20496E76657274696E67206669656C64206D617070696E67730A2020202020202020202020207661722069';
wwv_flow_api.g_varchar2_table(982) := '6E7665727465644D617070696E6773203D207B7D3B0A202020202020202020202020766172206D617070696E6773203D20746869732E6F7074696F6E732E6669656C644D617070696E67733B0A202020202020202020202020666F722028766172207072';
wwv_flow_api.g_varchar2_table(983) := '6F7020696E206D617070696E677329207B0A202020202020202020202020202020206966286D617070696E67732E6861734F776E50726F70657274792870726F702929207B0A2020202020202020202020202020202020202020696E7665727465644D61';
wwv_flow_api.g_varchar2_table(984) := '7070696E67735B6D617070696E67735B70726F705D5D203D2070726F703B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A20202020202020202020202072657475726E20746869732E6170706C794D617070696E67';
wwv_flow_api.g_varchar2_table(985) := '7328696E7665727465644D617070696E67732C20636F6D6D656E744A534F4E293B0A20202020202020207D2C0A0A20202020202020206170706C7945787465726E616C4D617070696E67733A2066756E6374696F6E28636F6D6D656E744A534F4E29207B';
wwv_flow_api.g_varchar2_table(986) := '0A202020202020202020202020766172206D617070696E6773203D20746869732E6F7074696F6E732E6669656C644D617070696E67733B0A20202020202020202020202072657475726E20746869732E6170706C794D617070696E6773286D617070696E';
wwv_flow_api.g_varchar2_table(987) := '67732C20636F6D6D656E744A534F4E293B0A20202020202020207D2C0A0A20202020202020206170706C794D617070696E67733A2066756E6374696F6E286D617070696E67732C20636F6D6D656E744A534F4E29207B0A20202020202020202020202076';
wwv_flow_api.g_varchar2_table(988) := '617220726573756C74203D207B7D3B0A0A202020202020202020202020666F7228766172206B65793120696E20636F6D6D656E744A534F4E29207B0A202020202020202020202020202020206966286B65793120696E206D617070696E677329207B0A20';
wwv_flow_api.g_varchar2_table(989) := '20202020202020202020202020202020202020766172206B657932203D206D617070696E67735B6B6579315D3B0A2020202020202020202020202020202020202020726573756C745B6B6579325D203D20636F6D6D656E744A534F4E5B6B6579315D3B0A';
wwv_flow_api.g_varchar2_table(990) := '202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020202020202072657475726E20726573756C743B0A20202020202020207D0A0A202020207D3B0A0A20202020242E666E2E636F6D6D656E7473203D206675';
wwv_flow_api.g_varchar2_table(991) := '6E6374696F6E286F7074696F6E7329207B0A202020202020202072657475726E20746869732E656163682866756E6374696F6E2829207B0A20202020202020202020202076617220636F6D6D656E7473203D204F626A6563742E63726561746528436F6D';
wwv_flow_api.g_varchar2_table(992) := '6D656E7473293B0A202020202020202020202020242E6461746128746869732C2027636F6D6D656E7473272C20636F6D6D656E7473293B0A202020202020202020202020636F6D6D656E74732E696E6974286F7074696F6E73207C7C207B7D2C20746869';
wwv_flow_api.g_varchar2_table(993) := '73293B0A20202020202020207D293B0A202020207D3B0A7D29293B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(39827936981613196398)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/jquery-comments.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A6A71756572792D636F6D6D656E74732E6A7320312E352E300A0A2863292032303137204A6F6F6E612054796B6B796CC3A4696E656E2C205669696D6120536F6C7574696F6E73204F790A6A71756572792D636F6D6D656E7473206D61792062652066';
wwv_flow_api.g_varchar2_table(2) := '7265656C7920646973747269627574656420756E64657220746865204D4954206C6963656E73652E0A466F7220616C6C2064657461696C7320616E6420646F63756D656E746174696F6E3A0A687474703A2F2F7669696D612E6769746875622E696F2F6A';
wwv_flow_api.g_varchar2_table(3) := '71756572792D636F6D6D656E74732F2A2F0A0A2E6A71756572792D636F6D6D656E7473202A207B0A09626F782D73697A696E673A20626F726465722D626F783B0A09746578742D736861646F773A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D';
wwv_flow_api.g_varchar2_table(4) := '656E747320615B687265665D3A6E6F74282E74616729207B0A09636F6C6F723A20233237393365363B0A09746578742D6465636F726174696F6E3A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320615B687265665D3A6E6F74282E74';
wwv_flow_api.g_varchar2_table(5) := '6167293A686F766572207B0A09746578742D6465636F726174696F6E3A20756E6465726C696E653B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612C202E6A71756572792D636F6D6D656E747320696E7075742C202E6A7175';
wwv_flow_api.g_varchar2_table(6) := '6572792D636F6D6D656E747320627574746F6E207B0A092D7765626B69742D617070656172616E63653A206E6F6E653B0A092D6D6F7A2D617070656172616E63653A206E6F6E653B0A092D6D732D617070656172616E63653A206E6F6E653B0A09617070';
wwv_flow_api.g_varchar2_table(7) := '656172616E63653A206E6F6E653B0A0A09766572746963616C2D616C69676E3A20746F703B0A09626F726465722D7261646975733A20303B0A096D617267696E3A20303B0A0970616464696E673A20303B0A09626F726465723A20303B0A096F75746C69';
wwv_flow_api.g_varchar2_table(8) := '6E653A20303B0A096261636B67726F756E643A207267626128302C20302C20302C2030293B0A7D0A0A2E6A71756572792D636F6D6D656E747320627574746F6E207B0A09766572746963616C2D616C69676E3A20696E68657269743B0A7D0A0A2E6A7175';
wwv_flow_api.g_varchar2_table(9) := '6572792D636F6D6D656E7473202E746167207B0A09636F6C6F723A20696E68657269743B0A09666F6E742D73697A653A20302E39656D3B0A096C696E652D6865696768743A20312E32656D3B0A096261636B67726F756E643A20236464643B0A09626F72';
wwv_flow_api.g_varchar2_table(10) := '6465723A2031707820736F6C696420236363633B0A0970616464696E673A20302E3035656D20302E34656D3B0A09637572736F723A20706F696E7465723B0A09666F6E742D7765696768743A206E6F726D616C3B0A09626F726465722D7261646975733A';
wwv_flow_api.g_varchar2_table(11) := '2031656D3B0A097472616E736974696F6E3A20616C6C20302E3273206C696E6561723B0A0977686974652D73706163653A206E6F777261703B0A09646973706C61793A20696E6C696E652D626C6F636B3B0A09746578742D6465636F726174696F6E3A20';
wwv_flow_api.g_varchar2_table(12) := '6E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E6174746163686D656E7473202E746167207B0A0977686974652D73706163653A206E6F726D616C3B0A09776F72642D627265616B3A20627265616B2D616C6C3B0A0A0970616464696E';
wwv_flow_api.g_varchar2_table(13) := '673A20302E3035656D20302E35656D3B0A096C696E652D6865696768743A20312E33656D3B0A0A096D617267696E2D746F703A20302E33656D3B0A096D617267696E2D72696768743A20302E35656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473';
wwv_flow_api.g_varchar2_table(14) := '202E6174746163686D656E7473202E746167203E20693A66697273742D6368696C64207B0A096D617267696E2D72696768743A20302E34656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E6174746163686D656E7473202E746167202E6465';
wwv_flow_api.g_varchar2_table(15) := '6C657465207B0A09646973706C61793A20696E6C696E653B0A09666F6E742D73697A653A20313470783B0A09636F6C6F723A20233838383B0A090A09706F736974696F6E3A2072656C61746976653B0A0970616464696E673A203270783B0A0970616464';
wwv_flow_api.g_varchar2_table(16) := '696E672D72696768743A203470783B0A0972696768743A202D3470783B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E6174746163686D656E7473202E7461673A686F766572202E64656C657465207B0A09636F6C6F723A20626C61636B3B0A7D';
wwv_flow_api.g_varchar2_table(17) := '0A0A2E6A71756572792D636F6D6D656E7473202E7461673A686F766572207B0A09746578742D6465636F726174696F6E3A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E7461673A6E6F74282E64656C657461626C65293A686F76';
wwv_flow_api.g_varchar2_table(18) := '6572207B0A096261636B67726F756E642D636F6C6F723A20236438656466383B0A09626F726465722D636F6C6F723A20233237393365363B0A7D0A0A2E6A71756572792D636F6D6D656E7473205B636F6E74656E744564697461626C653D747275655D3A';
wwv_flow_api.g_varchar2_table(19) := '656D7074793A6E6F74283A666F637573293A6265666F72657B0A20202020636F6E74656E743A6174747228646174612D706C616365686F6C646572293B0A20202020636F6C6F723A20234343433B0A20202020706F736974696F6E3A20696E6865726974';
wwv_flow_api.g_varchar2_table(20) := '3B0A20202020706F696E7465722D6576656E74733A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320692E6661207B0A0977696474683A2031656D3B0A096865696768743A2031656D3B0A096261636B67726F756E642D73697A653A20';
wwv_flow_api.g_varchar2_table(21) := '636F7665723B0A09746578742D616C69676E3A2063656E7465723B0A7D0A0A2E6A71756572792D636F6D6D656E747320692E66612E696D6167653A6265666F7265207B0A09636F6E74656E743A2022223B0A7D0A0A2E6A71756572792D636F6D6D656E74';
wwv_flow_api.g_varchar2_table(22) := '73202E7370696E6E6572207B0A09666F6E742D73697A653A2032656D3B0A09746578742D616C69676E3A2063656E7465723B0A0970616464696E673A20302E35656D3B0A096D617267696E3A20303B0A09636F6C6F723A20233636363B0A7D0A0A2E6A71';
wwv_flow_api.g_varchar2_table(23) := '756572792D636F6D6D656E7473202E7370696E6E65722E696E6C696E65207B0A09666F6E742D73697A653A20696E68657269743B0A0970616464696E673A20303B0A09636F6C6F723A20236666663B0A7D0A0A2E6A71756572792D636F6D6D656E747320';
wwv_flow_api.g_varchar2_table(24) := '756C207B0A096C6973742D7374796C653A206E6F6E653B0A0970616464696E673A20303B0A096D617267696E3A20303B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E70726F66696C652D70696374757265207B0A09666C6F61743A206C656674';
wwv_flow_api.g_varchar2_table(25) := '3B0A0977696474683A20332E3672656D3B0A096865696768743A20332E3672656D3B0A096D61782D77696474683A20353070783B0A096D61782D6865696768743A20353070783B0A096261636B67726F756E642D73697A653A20636F7665723B0A096261';
wwv_flow_api.g_varchar2_table(26) := '636B67726F756E642D7265706561743A206E6F2D7265706561743B0A096261636B67726F756E642D706F736974696F6E3A2063656E7465722063656E7465723B0A7D0A0A2E6A71756572792D636F6D6D656E747320692E70726F66696C652D7069637475';
wwv_flow_api.g_varchar2_table(27) := '7265207B0A09666F6E742D73697A653A20332E34656D3B0A09746578742D616C69676E3A2063656E7465723B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E70726F66696C652D706963747572652E726F756E64207B0A09626F726465722D7261';
wwv_flow_api.g_varchar2_table(28) := '646975733A203530253B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E636F6D6D656E74696E672D6669656C642E6D61696E7B0A096D617267696E2D626F74746F6D3A20302E3735656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E';
wwv_flow_api.g_varchar2_table(29) := '636F6D6D656E74696E672D6669656C642E6D61696E202E70726F66696C652D70696374757265207B0A096D617267696E2D626F74746F6D3A203172656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D77726170706572';
wwv_flow_api.g_varchar2_table(30) := '207B0A096F766572666C6F773A2068696464656E3B0A0970616464696E672D6C6566743A20313570783B0A09706F736974696F6E3A2072656C61746976653B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D777261707065';
wwv_flow_api.g_varchar2_table(31) := '723A6265666F7265207B0A09636F6E74656E743A202220223B0A09706F736974696F6E3A206162736F6C7574653B0A09626F726465723A2035707820736F6C696420234435443544353B0A096C6566743A203570783B0A09746F703A20303B0A09776964';
wwv_flow_api.g_varchar2_table(32) := '74683A20313070783B0A096865696768743A20313070783B0A09626F782D73697A696E673A20626F726465722D626F783B0A09626F726465722D626F74746F6D2D636F6C6F723A207267626128302C20302C20302C2030293B0A09626F726465722D6C65';
wwv_flow_api.g_varchar2_table(33) := '66742D636F6C6F723A207267626128302C20302C20302C2030293B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D777261707065723A6166746572207B0A09636F6E74656E743A202220223B0A09706F736974696F6E3A20';
wwv_flow_api.g_varchar2_table(34) := '6162736F6C7574653B0A09626F726465723A2037707820736F6C696420234646463B0A096C6566743A203770783B0A09746F703A203170783B0A0977696474683A20313070783B0A096865696768743A20313070783B0A09626F782D73697A696E673A20';
wwv_flow_api.g_varchar2_table(35) := '626F726465722D626F783B0A09626F726465722D626F74746F6D2D636F6C6F723A207267626128302C20302C20302C2030293B0A09626F726465722D6C6566742D636F6C6F723A207267626128302C20302C20302C2030293B0A7D0A0A2E6A7175657279';
wwv_flow_api.g_varchar2_table(36) := '2D636F6D6D656E7473202E74657874617265612D77726170706572202E696E6C696E652D627574746F6E207B0A09637572736F723A20706F696E7465723B0A0972696768743A20303B0A097A2D696E6465783A2031303B0A09706F736974696F6E3A2061';
wwv_flow_api.g_varchar2_table(37) := '62736F6C7574653B0A09626F726465723A202E35656D20736F6C6964207267626128302C302C302C30293B0A09626F782D73697A696E673A20636F6E74656E742D626F783B0A09666F6E742D73697A653A20696E68657269743B0A096F766572666C6F77';
wwv_flow_api.g_varchar2_table(38) := '3A2068696464656E3B0A096F7061636974793A20302E353B0A0A092D7765626B69742D757365722D73656C6563743A206E6F6E653B0A092D6D6F7A2D757365722D73656C6563743A206E6F6E653B0A092D6D732D757365722D73656C6563743A206E6F6E';
wwv_flow_api.g_varchar2_table(39) := '653B0A09757365722D73656C6563743A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D77726170706572202E696E6C696E652D627574746F6E3A686F766572207B0A096F7061636974793A20313B0A7D0A0A';
wwv_flow_api.g_varchar2_table(40) := '2E6A71756572792D636F6D6D656E74733A6E6F74282E6D6F62696C6529202E636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C65202E74657874617265612D77726170706572202E696E6C696E652D627574746F6E207B0A096D61726769';
wwv_flow_api.g_varchar2_table(41) := '6E2D72696768743A20313570783B092F2A2042656361757365206F66207363726F6C6C626172202A2F0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D77726170706572202E696E6C696E652D627574746F6E2069207B0A09';
wwv_flow_api.g_varchar2_table(42) := '666F6E742D73697A653A20312E32656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D77726170706572202E75706C6F616420696E707574207B0A09637572736F723A20706F696E7465723B0A09706F736974696F6E3A';
wwv_flow_api.g_varchar2_table(43) := '206162736F6C7574653B0A09746F703A20303B0A0972696768743A20303B0A096D696E2D77696474683A20313030253B0A096865696768743A20313030253B0A096D617267696E3A20303B0A0970616464696E673A20303B0A096F7061636974793A2030';
wwv_flow_api.g_varchar2_table(44) := '3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265612D77726170706572202E636C6F7365207B0A0977696474683A2031656D3B0A096865696768743A2031656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E746578';
wwv_flow_api.g_varchar2_table(45) := '74617265612D77726170706572202E7465787461726561207B0A096D617267696E3A20303B0A096F75746C696E653A20303B0A096F766572666C6F772D793A206175746F3B0A096F766572666C6F772D783A2068696464656E3B0A09637572736F723A20';
wwv_flow_api.g_varchar2_table(46) := '746578743B0A0A09626F726465723A2031707820736F6C696420234343433B3B0A096261636B67726F756E643A20234646463B0A09666F6E742D73697A653A2031656D3B0A096C696E652D6865696768743A20312E3435656D3B0A0970616464696E673A';
wwv_flow_api.g_varchar2_table(47) := '202E3235656D202E38656D3B0A0970616464696E672D72696768743A2032656D3B0A7D0A0A2E6A71756572792D636F6D6D656E74733A6E6F74282E6D6F62696C6529202E636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C65202E746578';
wwv_flow_api.g_varchar2_table(48) := '74617265612D77726170706572202E7465787461726561207B0A0970616464696E672D72696768743A2063616C632832656D202B2031357078293B092F2A2042656361757365206F66207363726F6C6C626172202A2F0A7D0A0A2E6A71756572792D636F';
wwv_flow_api.g_varchar2_table(49) := '6D6D656E7473202E74657874617265612D77726170706572202E636F6E74726F6C2D726F77203E202E6174746163686D656E7473207B0A0970616464696E672D746F703A202E33656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874';
wwv_flow_api.g_varchar2_table(50) := '617265612D77726170706572202E636F6E74726F6C2D726F77203E207370616E207B0A09666C6F61743A2072696768743B0A096C696E652D6865696768743A20312E36656D3B0A096D617267696E2D746F703A202E34656D3B0A09626F726465723A2031';
wwv_flow_api.g_varchar2_table(51) := '707820736F6C6964207267626128302C20302C20302C2030293B0A09636F6C6F723A20234646463B0A0970616464696E673A20302031656D3B0A09666F6E742D73697A653A2031656D3B0A096F7061636974793A202E353B0A7D0A0A2E6A71756572792D';
wwv_flow_api.g_varchar2_table(52) := '636F6D6D656E7473202E74657874617265612D77726170706572202E636F6E74726F6C2D726F77203E207370616E3A6E6F74283A66697273742D6368696C6429207B0A096D617267696E2D72696768743A202E35656D3B0A7D0A0A2E6A71756572792D63';
wwv_flow_api.g_varchar2_table(53) := '6F6D6D656E7473202E74657874617265612D77726170706572202E636F6E74726F6C2D726F77203E207370616E2E656E61626C6564207B0A096F7061636974793A20313B0A09637572736F723A20706F696E7465723B0A7D0A0A2E6A71756572792D636F';
wwv_flow_api.g_varchar2_table(54) := '6D6D656E7473202E74657874617265612D77726170706572202E636F6E74726F6C2D726F77203E207370616E3A6E6F74282E656E61626C656429207B0A09706F696E7465722D6576656E74733A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D65';
wwv_flow_api.g_varchar2_table(55) := '6E7473202E74657874617265612D77726170706572202E636F6E74726F6C2D726F77203E207370616E2E656E61626C65643A686F766572207B0A096F7061636974793A202E393B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E74657874617265';
wwv_flow_api.g_varchar2_table(56) := '612D77726170706572202E636F6E74726F6C2D726F77203E207370616E2E75706C6F6164207B0A09706F736974696F6E3A2072656C61746976653B0A096F766572666C6F773A2068696464656E3B0A096261636B67726F756E642D636F6C6F723A202339';
wwv_flow_api.g_varchar2_table(57) := '39393B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E207B0A09636C6561723A20626F74683B0A0A09636F6C6F723A20233939393B0A09626F726465722D626F74746F6D3A2032707820736F6C696420234343433B';
wwv_flow_api.g_varchar2_table(58) := '0A096C696E652D6865696768743A2032656D3B0A09666F6E742D73697A653A2031656D3B0A096D617267696E2D626F74746F6D3A20302E35656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E61766967';
wwv_flow_api.g_varchar2_table(59) := '6174696F6E2D77726170706572207B0A09706F736974696F6E3A2072656C61746976653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C69207B0A09646973706C61793A20696E6C696E652D626C6F636B3B0A';
wwv_flow_api.g_varchar2_table(60) := '09706F736974696F6E3A2072656C61746976653B0A0970616464696E673A20302031656D3B0A09637572736F723A20706F696E7465723B0A09746578742D616C69676E3A2063656E7465723B0A0A092D7765626B69742D757365722D73656C6563743A20';
wwv_flow_api.g_varchar2_table(61) := '6E6F6E653B0A092D6D6F7A2D757365722D73656C6563743A206E6F6E653B0A092D6D732D757365722D73656C6563743A206E6F6E653B0A09757365722D73656C6563743A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E61';
wwv_flow_api.g_varchar2_table(62) := '7669676174696F6E206C692E6163746976652C0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C693A686F766572207B0A09636F6C6F723A20233030303B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E';
wwv_flow_api.g_varchar2_table(63) := '617669676174696F6E206C692E6163746976653A6166746572207B0A09636F6E74656E743A202220223B0A09646973706C61793A20626C6F636B3B0A0972696768743A20303B0A096865696768743A203270783B0A096261636B67726F756E643A202330';
wwv_flow_api.g_varchar2_table(64) := '30303B0A09706F736974696F6E3A206162736F6C7574653B0A09626F74746F6D3A202D3270783B0A096C6566743A20303B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C695B646174612D736F72742D6B6579';
wwv_flow_api.g_varchar2_table(65) := '3D226174746163686D656E7473225D207B0A09666C6F61743A2072696768743B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C695B646174612D736F72742D6B65793D226174746163686D656E7473225D2069';
wwv_flow_api.g_varchar2_table(66) := '207B0A096D617267696E2D72696768743A20302E3235656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665207B0A09646973706C61';
wwv_flow_api.g_varchar2_table(67) := '793A206E6F6E653B0A7D0A0A406D656469612073637265656E20616E6420286D61782D77696474683A20363030707829207B0A092E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D7772617070';
wwv_flow_api.g_varchar2_table(68) := '6572207B0A0909646973706C61793A206E6F6E653B0A097D0A092E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665207B0A0909646973706C61793A';
wwv_flow_api.g_varchar2_table(69) := '20696E6C696E653B0A097D0A7D0A0A2E6A71756572792D636F6D6D656E74732E726573706F6E7369766520756C2E6E617669676174696F6E202E6E617669676174696F6E2D77726170706572207B0A09646973706C61793A206E6F6E653B0A7D0A2E6A71';
wwv_flow_api.g_varchar2_table(70) := '756572792D636F6D6D656E74732E726573706F6E7369766520756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665207B0A09646973706C61793A20696E6C696E653B0A7D0A0A2E6A7175657279';
wwv_flow_api.g_varchar2_table(71) := '2D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665206C692E7469746C65207B0A0970616464696E673A203020312E35656D3B0A7D0A0A2E6A71756572792D636F6D6D';
wwv_flow_api.g_varchar2_table(72) := '656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665206C692E7469746C65206865616465723A6166746572207B0A20202020646973706C61793A20696E6C696E652D626C6F636B3B';
wwv_flow_api.g_varchar2_table(73) := '0A20202020636F6E74656E743A2022223B0A20202020626F726465722D6C6566743A20302E33656D20736F6C6964207267626128302C20302C20302C2030292021696D706F7274616E743B0A20202020626F726465722D72696768743A20302E33656D20';
wwv_flow_api.g_varchar2_table(74) := '736F6C6964207267626128302C20302C20302C2030292021696D706F7274616E743B0A20202020626F726465722D746F703A20302E34656D20736F6C696420234343433B0A202020206D617267696E2D6C6566743A20302E35656D3B0A20202020706F73';
wwv_flow_api.g_varchar2_table(75) := '6974696F6E3A2072656C61746976653B0A20202020746F703A202D302E31656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665206C';
wwv_flow_api.g_varchar2_table(76) := '692E7469746C652E616374697665206865616465723A61667465722C0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E73697665206C692E7469746C653A';
wwv_flow_api.g_varchar2_table(77) := '686F766572206865616465723A6166746572207B0A09626F726465722D746F702D636F6C6F723A20233030303B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E207B0A09646973706C61793A206E6F6E653B0A09706F73';
wwv_flow_api.g_varchar2_table(78) := '6974696F6E3A206162736F6C7574653B0A096261636B67726F756E643A20234646463B0A097A2D696E6465783A2039393B0A096C696E652D6865696768743A20312E32656D3B0A0A09626F726465723A2031707820736F6C696420234343433B0A09626F';
wwv_flow_api.g_varchar2_table(79) := '782D736861646F773A2030203670782031327078207267626128302C20302C20302C20302E313735293B0A092D7765626B69742D626F782D736861646F773A2030203670782031327078207267626128302C20302C20302C20302E313735293B0A092D6D';
wwv_flow_api.g_varchar2_table(80) := '6F7A2D626F782D736861646F773A2030203670782031327078207267626128302C20302C20302C20302E313735293B0A092D6D732D626F782D736861646F773A2030203670782031327078207267626128302C20302C20302C20302E313735293B0A7D0A';
wwv_flow_api.g_varchar2_table(81) := '0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E2E6175746F636F6D706C657465207B0A096D617267696E2D746F703A20302E3235656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E206C69';
wwv_flow_api.g_varchar2_table(82) := '207B0A09646973706C61793A20626C6F636B3B0A0977686974652D73706163653A206E6F777261703B0A09636C6561723A20626F74683B0A0970616464696E673A20302E36656D3B0A09666F6E742D7765696768743A206E6F726D616C3B0A0963757273';
wwv_flow_api.g_varchar2_table(83) := '6F723A20706F696E7465723B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E206C692E616374697665207B0A096261636B67726F756E643A20234545453B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64';
wwv_flow_api.g_varchar2_table(84) := '726F70646F776E206C692061207B0A09646973706C61793A20626C6F636B3B0A09746578742D6465636F726174696F6E3A206E6F6E653B0A09636F6C6F723A20696E68657269743B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70';
wwv_flow_api.g_varchar2_table(85) := '646F776E206C69202E70726F66696C652D70696374757265207B0A09666C6F61743A206C6566743B0A0977696474683A20322E34656D3B0A096865696768743A20322E34656D3B0A096D617267696E2D72696768743A20302E35656D3B0A7D0A0A2E6A71';
wwv_flow_api.g_varchar2_table(86) := '756572792D636F6D6D656E747320756C2E64726F70646F776E206C69202E64657461696C73207B0A09646973706C61793A20696E6C696E652D626C6F636B3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E206C69202E';
wwv_flow_api.g_varchar2_table(87) := '6E616D65207B0A09666F6E742D7765696768743A20626F6C643B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E206C69202E64657461696C732E6E6F2D656D61696C207B0A096C696E652D6865696768743A20322E3465';
wwv_flow_api.g_varchar2_table(88) := '6D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E64726F70646F776E206C69202E656D61696C207B0A09636F6C6F723A20233939393B0A09666F6E742D73697A653A20302E3935656D3B0A096D617267696E2D746F703A20302E31656D3B';
wwv_flow_api.g_varchar2_table(89) := '0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E7369766520756C2E64726F70646F776E207B0A096C6566743A20303B0A0977696474683A203130';
wwv_flow_api.g_varchar2_table(90) := '30253B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E7369766520756C2E64726F70646F776E206C69207B0A09636F6C6F723A20233030303B0A';
wwv_flow_api.g_varchar2_table(91) := '7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E7369766520756C2E64726F70646F776E206C692E616374697665207B0A09636F6C6F723A20234646';
wwv_flow_api.g_varchar2_table(92) := '463B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E7369766520756C2E64726F70646F776E206C693A686F7665723A6E6F74282E616374697665';
wwv_flow_api.g_varchar2_table(93) := '29207B0A096261636B67726F756E643A20234635463546353B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E202E6E617669676174696F6E2D777261707065722E726573706F6E7369766520756C2E64726F70646F';
wwv_flow_api.g_varchar2_table(94) := '776E206C693A6166746572207B0A09646973706C61793A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E6E6F2D64617461207B0A09646973706C61793A206E6F6E653B0A096D617267696E3A2031656D3B0A09746578742D616C69';
wwv_flow_api.g_varchar2_table(95) := '676E3A2063656E7465723B0A09666F6E742D73697A653A20312E35656D3B0A09636F6C6F723A20234343433B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E3A656D707479207E202E6E6F2D636F6D6D656E7473207B0A09646973';
wwv_flow_api.g_varchar2_table(96) := '706C61793A20696E68657269743B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C236174746163686D656E742D6C6973743A656D707479207E202E6E6F2D6174746163686D656E7473207B0A09646973706C61793A20696E68657269743B0A7D';
wwv_flow_api.g_varchar2_table(97) := '0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74207B0A09636C6561723A20626F74683B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D656E';
wwv_flow_api.g_varchar2_table(98) := '742D777261707065722C0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E746F67676C652D616C6C2C0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D656E74696E672D66';
wwv_flow_api.g_varchar2_table(99) := '69656C64207B0A0970616464696E673A202E35656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D656E742D77726170706572207B0A09626F726465722D746F703A2031707820736F';
wwv_flow_api.g_varchar2_table(100) := '6C696420234444443B0A096F766572666C6F773A2068696464656E3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E203E206C692E636F6D6D656E743A66697273742D6368696C64203E202E636F6D6D656E742D77726170706572';
wwv_flow_api.g_varchar2_table(101) := '207B0A09626F726465722D746F703A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D656E742D77726170706572203E202E70726F66696C652D70696374757265207B0A09';
wwv_flow_api.g_varchar2_table(102) := '6D617267696E2D72696768743A203172656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E742074696D65207B0A09666C6F61743A2072696768743B0A096C696E652D6865696768743A20312E34656D';
wwv_flow_api.g_varchar2_table(103) := '3B0A096D617267696E2D6C6566743A202E35656D3B0A09666F6E742D73697A653A20302E38656D3B0A09636F6C6F723A20233636363B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D65';
wwv_flow_api.g_varchar2_table(104) := '6E742D686561646572207B0A096C696E652D6865696768743A20312E34656D3B0A09776F72642D627265616B3A20627265616B2D776F72643B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F';
wwv_flow_api.g_varchar2_table(105) := '6D6D656E742D686561646572203E202A207B0A096D617267696E2D72696768743A202E3572656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D656E742D686561646572202E6E616D';
wwv_flow_api.g_varchar2_table(106) := '65207B0A09666F6E742D7765696768743A20626F6C643B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E636F6D6D656E742D686561646572202E7265706C792D746F207B0A09636F6C6F723A2023';
wwv_flow_api.g_varchar2_table(107) := '3939393B0A09666F6E742D73697A653A202E38656D3B0A09666F6E742D7765696768743A206E6F726D616C3B0A09766572746963616C2D616C69676E3A20746F703B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F';
wwv_flow_api.g_varchar2_table(108) := '6D6D656E74202E636F6D6D656E742D686561646572202E7265706C792D746F2069207B0A096D617267696E2D72696768743A202E323572656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E63';
wwv_flow_api.g_varchar2_table(109) := '6F6D6D656E742D686561646572202E6E6577207B0A096261636B67726F756E643A20233237393365363B0A09666F6E742D73697A653A20302E38656D3B0A0970616464696E673A20302E32656D20302E36656D3B0A09636F6C6F723A20236666663B0A09';
wwv_flow_api.g_varchar2_table(110) := '666F6E742D7765696768743A206E6F726D616C3B0A09626F726465722D7261646975733A2031656D3B0A09766572746963616C2D616C69676E3A20626F74746F6D3B0A09776F72642D627265616B3A206E6F726D616C3B0A7D0A0A2E6A71756572792D63';
wwv_flow_api.g_varchar2_table(111) := '6F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E777261707065727B0A096C696E652D6865696768743A20312E34656D3B0A096F766572666C6F773A2068696464656E3B0A7D0A0A2E6A71756572792D636F6D6D656E74732E6D6F62';
wwv_flow_api.g_varchar2_table(112) := '696C6520756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473206C692E636F6D6D656E74202E777261707065727B0A096F766572666C6F773A2076697369626C653B0A7D0A0A2F2A20436F6E74656E74202A2F0A2E6A71';
wwv_flow_api.g_varchar2_table(113) := '756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E77726170706572202E636F6E74656E74207B0A0977686974652D73706163653A207072652D6C696E653B0A09776F72642D627265616B3A20627265616B2D776F7264';
wwv_flow_api.g_varchar2_table(114) := '3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E77726170706572202E636F6E74656E742074696D652E656469746564207B0A09666C6F61743A20696E68657269743B0A096D617267696E3A2030';
wwv_flow_api.g_varchar2_table(115) := '3B0A09666F6E742D73697A653A202E39656D3B0A09666F6E742D7374796C653A206974616C69633B0A09636F6C6F723A20233939393B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E7772617070';
wwv_flow_api.g_varchar2_table(116) := '6572202E636F6E74656E742074696D652E6564697465643A6265666F7265207B0A09636F6E74656E743A2022202D20223B0A7D0A0A2F2A204174746163686D656E7473202A2F0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E63';
wwv_flow_api.g_varchar2_table(117) := '6F6D6D656E74202E77726170706572202E6174746163686D656E7473202E746167733A6E6F74283A656D70747929207B0A096D617267696E2D626F74746F6D3A20302E35656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E20';
wwv_flow_api.g_varchar2_table(118) := '6C692E636F6D6D656E74202E77726170706572202E6174746163686D656E7473202E7072657669657773202E70726576696577207B0A09646973706C61793A20696E6C696E652D626C6F636B3B0A096D617267696E2D746F703A202E3235656D3B0A096D';
wwv_flow_api.g_varchar2_table(119) := '617267696E2D72696768743A202E3235656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E77726170706572202E6174746163686D656E7473202E7072657669657773202E7072657669657720';
wwv_flow_api.g_varchar2_table(120) := '3E202A207B0A096D61782D77696474683A20313030253B0A096D61782D6865696768743A2032303070783B0A0977696474683A206175746F3B0A096865696768743A206175746F3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E';
wwv_flow_api.g_varchar2_table(121) := '206C692E636F6D6D656E74202E77726170706572202E6174746163686D656E7473202E7072657669657773202E70726576696577203E202A3A666F637573207B0A096F75746C696E653A206E6F6E653B0A7D0A0A2F2A20416374696F6E73202A2F0A2E6A';
wwv_flow_api.g_varchar2_table(122) := '71756572792D636F6D6D656E74732E6D6F62696C6520756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73207B0A09666F6E742D73697A653A2031656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E';
wwv_flow_api.g_varchar2_table(123) := '636F6D6D656E74202E616374696F6E73203E202A207B0A09636F6C6F723A20233939393B0A09666F6E742D7765696768743A20626F6C643B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374';
wwv_flow_api.g_varchar2_table(124) := '696F6E73202E616374696F6E207B0A09646973706C61793A20696E6C696E652D626C6F636B3B0A09637572736F723A20706F696E7465723B0A096D617267696E2D6C6566743A2031656D3B0A096D617267696E2D72696768743A2031656D3B0A096C696E';
wwv_flow_api.g_varchar2_table(125) := '652D6865696768743A20312E35656D3B0A09666F6E742D73697A653A20302E39656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E3A66697273742D6368';
wwv_flow_api.g_varchar2_table(126) := '696C64207B0A096D617267696E2D6C6566743A20303B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E7570766F7465207B0A09637572736F723A20696E68';
wwv_flow_api.g_varchar2_table(127) := '657269743B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E7570766F7465202E7570766F74652D636F756E74207B0A096D617267696E2D72696768743A20';
wwv_flow_api.g_varchar2_table(128) := '2E35656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E7570766F7465202E7570766F74652D636F756E743A656D707479207B0A09646973706C61793A';
wwv_flow_api.g_varchar2_table(129) := '206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E7570766F74652069207B0A09637572736F723A20706F696E7465723B0A7D0A0A2E6A717565';
wwv_flow_api.g_varchar2_table(130) := '72792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E3A6E6F74282E7570766F7465293A686F7665722C0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D';
wwv_flow_api.g_varchar2_table(131) := '656E74202E616374696F6E73202E616374696F6E2E7570766F74653A6E6F74282E686967686C696768742D666F6E742920693A686F766572207B0A09636F6C6F723A20233636363B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E';
wwv_flow_api.g_varchar2_table(132) := '206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E64656C657465207B0A096F7061636974793A20302E353B0A09706F696E7465722D6576656E74733A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D';
wwv_flow_api.g_varchar2_table(133) := '61696E206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E64656C6574652E656E61626C6564207B0A096F7061636974793A20313B0A09706F696E7465722D6576656E74733A206175746F3B0A7D0A0A2E6A71756572792D636F6D6D';
wwv_flow_api.g_varchar2_table(134) := '656E747320756C236174746163686D656E742D6C697374206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E3A6E6F74282E64656C65746529207B0A09646973706C61793A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E';
wwv_flow_api.g_varchar2_table(135) := '747320756C236174746163686D656E742D6C697374206C692E636F6D6D656E74202E616374696F6E73202E616374696F6E2E64656C657465207B0A096D617267696E3A20303B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C23617474616368';
wwv_flow_api.g_varchar2_table(136) := '6D656E742D6C697374206C692E636F6D6D656E74202E616374696F6E73202E736570617261746F72207B0A09646973706C61793A206E6F6E653B0A7D0A0A0A2F2A204368696C6420636F6D6D656E7473202A2F0A2E6A71756572792D636F6D6D656E7473';
wwv_flow_api.g_varchar2_table(137) := '20756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473203E202A3A6265666F7265207B202F2A204D617267696E20666F72207365636F6E64206C6576656C20636F6E74656E74202A2F0A09636F6E74656E743A2022223B';
wwv_flow_api.g_varchar2_table(138) := '0A096865696768743A203170783B0A09666C6F61743A206C6566743B0A0A0977696474683A2063616C6328332E36656D202B202E35656D293B092F2A2050726F66696C65207069637475726520776964746820706C7573206D617267696E202A2F0A096D';
wwv_flow_api.g_varchar2_table(139) := '61782D77696474683A2063616C632835307078202B202E35656D293B092F2A2050726F66696C652070696374757265206D617820776964746820706C7573206D617267696E202A2F0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E';
wwv_flow_api.g_varchar2_table(140) := '206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473202E70726F66696C652D70696374757265207B0A0977696474683A20322E3472656D3B0A096865696768743A20322E3472656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320';
wwv_flow_api.g_varchar2_table(141) := '756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E747320692E70726F66696C652D70696374757265207B0A09666F6E742D73697A653A20322E34656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D6169';
wwv_flow_api.g_varchar2_table(142) := '6E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473206C692E746F67676C652D616C6C207B0A0970616464696E672D746F703A20303B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74';
wwv_flow_api.g_varchar2_table(143) := '202E6368696C642D636F6D6D656E7473206C692E746F67676C652D616C6C207370616E3A66697273742D6368696C64207B0A09766572746963616C2D616C69676E3A206D6964646C653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61';
wwv_flow_api.g_varchar2_table(144) := '696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473206C692E746F67676C652D616C6C207370616E3A66697273742D6368696C643A686F766572207B0A09637572736F723A20706F696E7465723B0A09746578742D6465636F726174';
wwv_flow_api.g_varchar2_table(145) := '696F6E3A20756E6465726C696E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473206C692E746F67676C652D616C6C202E6361726574207B0A09646973706C';
wwv_flow_api.g_varchar2_table(146) := '61793A20696E6C696E652D626C6F636B3B0A09766572746963616C2D616C69676E3A206D6964646C653B0A0977696474683A20303B0A096865696768743A20303B0A0A096D617267696E2D6C6566743A202E35656D3B0A09626F726465723A202E33656D';
wwv_flow_api.g_varchar2_table(147) := '20736F6C69643B0A096D617267696E2D746F703A202E3335656D3B0A0A09626F726465722D6C6566742D636F6C6F723A207267626128302C20302C20302C2030293B0A09626F726465722D626F74746F6D2D636F6C6F723A207267626128302C20302C20';
wwv_flow_api.g_varchar2_table(148) := '302C2030293B0A09626F726465722D72696768742D636F6C6F723A207267626128302C20302C20302C2030293B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473';
wwv_flow_api.g_varchar2_table(149) := '206C692E746F67676C652D616C6C202E63617265742E7570207B0A09626F726465722D746F702D636F6C6F723A207267626128302C20302C20302C2030293B0A09626F726465722D626F74746F6D2D636F6C6F723A20696E68657269743B0A096D617267';
wwv_flow_api.g_varchar2_table(150) := '696E2D746F703A202D2E32656D3B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473202E746F67676C61626C652D7265706C79207B0A09646973706C61793A206E';
wwv_flow_api.g_varchar2_table(151) := '6F6E653B0A7D0A0A2E6A71756572792D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E74202E6368696C642D636F6D6D656E7473202E76697369626C65207B0A09646973706C61793A20696E68657269743B0A7D0A0A2E6A7175657279';
wwv_flow_api.g_varchar2_table(152) := '2D636F6D6D656E747320756C2E6D61696E206C692E636F6D6D656E742E68696464656E207B0A09646973706C61793A206E6F6E653B0A7D0A0A2F2A2045646974696E6720636F6D6D656E74202A2F0A2E6A71756572792D636F6D6D656E747320756C2E6D';
wwv_flow_api.g_varchar2_table(153) := '61696E206C692E636F6D6D656E742E65646974203E202E636F6D6D656E742D77726170706572203E202A3A6E6F74282E636F6D6D656E74696E672D6669656C6429207B0A09646973706C61793A206E6F6E653B0A7D0A0A2E6A71756572792D636F6D6D65';
wwv_flow_api.g_varchar2_table(154) := '6E747320756C2E6D61696E206C692E636F6D6D656E742E65646974203E202E636F6D6D656E742D77726170706572202E636F6D6D656E74696E672D6669656C64207B0A0970616464696E672D6C6566743A20302021696D706F7274616E743B0A09706164';
wwv_flow_api.g_varchar2_table(155) := '64696E672D72696768743A20302021696D706F7274616E743B0A7D0A0A2F2A204472616720262064726F70206174746163686D656E7473202A2F0A2E6A71756572792D636F6D6D656E74732E647261672D6F6E676F696E67207B0A096F766572666C6F77';
wwv_flow_api.g_varchar2_table(156) := '2D793A2068696464656E2021696D706F7274616E743B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E64726F707061626C652D6F7665726C6179207B0A09646973706C61793A207461626C653B0A09706F736974696F6E3A2066697865643B0A09';
wwv_flow_api.g_varchar2_table(157) := '7A2D696E6465783A2039393B0A0A09746F703A20303B0A096C6566743A20303B0A0977696474683A20313030253B0A096865696768743A20313030253B0A096261636B67726F756E643A207267626128302C302C302C302E33290A7D0A0A2E6A71756572';
wwv_flow_api.g_varchar2_table(158) := '792D636F6D6D656E7473202E64726F707061626C652D6F7665726C6179202E64726F707061626C652D636F6E7461696E6572207B0A09646973706C61793A207461626C652D63656C6C3B0A09766572746963616C2D616C69676E3A206D6964646C653B0A';
wwv_flow_api.g_varchar2_table(159) := '09746578742D616C69676E3A2063656E7465723B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E64726F707061626C652D6F7665726C6179202E64726F707061626C652D636F6E7461696E6572202E64726F707061626C65207B0A096261636B67';
wwv_flow_api.g_varchar2_table(160) := '726F756E643A20234646463B0A09636F6C6F723A20234343433B0A0970616464696E673A2036656D3B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E64726F707061626C652D6F7665726C6179202E64726F707061626C652D636F6E7461696E65';
wwv_flow_api.g_varchar2_table(161) := '72202E64726F707061626C652E647261672D6F766572207B0A09636F6C6F723A20233939393B0A7D0A0A2E6A71756572792D636F6D6D656E7473202E64726F707061626C652D6F7665726C6179202E64726F707061626C652D636F6E7461696E6572202E';
wwv_flow_api.g_varchar2_table(162) := '64726F707061626C652069207B0A096D617267696E2D626F74746F6D3A203570783B0A7D0A0A2F2A20526561642D6F6E6C79206D6F6465202A2F0A2E6A71756572792D636F6D6D656E74732E726561642D6F6E6C79202E636F6D6D656E74696E672D6669';
wwv_flow_api.g_varchar2_table(163) := '656C64207B0A09646973706C61793A206E6F6E653B0A7D0A2E6A71756572792D636F6D6D656E74732E726561642D6F6E6C79202E616374696F6E73207B0A09646973706C61793A206E6F6E653B0A7D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(39827961363862201605)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'css/jquery-comments.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C7320617065782C24202A2F0D0A77696E646F772E434F4D4D454E5453203D2077696E646F772E434F4D4D454E5453207C7C207B7D3B0D0A0D0A2F2F496E697469616C697A6520706C7567696E0D0A434F4D4D454E54532E696E6974';
wwv_flow_api.g_varchar2_table(2) := '69616C697A65203D2066756E6374696F6E28636F6E6669672C20696E697429207B0D0A0D0A2020202076617220726567696F6E4964203D20636F6E6669672E66756E6374696F6E616C69746965732E726567696F6E49643B0D0A2020202076617220636F';
wwv_flow_api.g_varchar2_table(3) := '6D6D656E74735769746850696E6773203D20434F4D4D454E54532E61646450696E67734A534F4E28636F6E6669672E636F6D6D656E74732C636F6E6669672E70696E67696E674C697374293B0D0A2020202076617220636667203D207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(4) := '2020200D0A20202020202020202F2F66756E6374696F6E616C69746965730D0A2020202020202020656E61626C655570766F74696E673A2066616C73652C0D0A0D0A2020202020202020656E61626C655265706C79696E673A20747275652C0D0A0D0A20';
wwv_flow_api.g_varchar2_table(5) := '20202020202020656E61626C6544656C6574696E673A20636F6E6669672E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E672C0D0A0D0A2020202020202020656E61626C6544656C6574696E67436F6D6D656E74576974685265';
wwv_flow_api.g_varchar2_table(6) := '706C6965733A20636F6E6669672E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965732C0D0A0D0A2020202020202020656E61626C6545646974696E673A20636F6E6669672E66756E';
wwv_flow_api.g_varchar2_table(7) := '6374696F6E616C69746965732E656E61626C6545646974696E672C0D0A0D0A2020202020202020656E61626C6550696E67696E673A20636F6E6669672E66756E6374696F6E616C69746965732E656E61626C6550696E67696E672C0D0A0D0A2020202020';
wwv_flow_api.g_varchar2_table(8) := '202020676574436F6D6D656E74733A2066756E6374696F6E28737563636573732C206572726F7229207B0D0A20202020202020202020202076617220636F6D6D656E74734172726179203D20636F6D6D656E74735769746850696E67733B0D0A20202020';
wwv_flow_api.g_varchar2_table(9) := '20202020202020207375636365737328636F6D6D656E74734172726179293B0D0A20202020202020207D2C0D0A0D0A202020202020202073656172636855736572733A2066756E6374696F6E287465726D2C20737563636573732C206572726F7229207B';
wwv_flow_api.g_varchar2_table(10) := '0D0A2020202020202020202020207375636365737328434F4D4D454E54532E66696C74657250696E67734C69737428636F6E6669672E70696E67696E674C6973742C7465726D29293B0D0A20202020202020207D2C0D0A0D0A2020202020202020706F73';
wwv_flow_api.g_varchar2_table(11) := '74436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B0D0A0D0A2020202020202020202020202F2F496E73657274206E657720636F6D6D656E740D0A20202020202020202020202061';
wwv_flow_api.g_varchar2_table(12) := '7065782E7365727665722E706C7567696E202820636F6E6669672E66756E6374696F6E616C69746965732E616A61784964656E7469666965722C207B0D0A20202020202020202020202020202020202020207830313A202749272C0D0A20202020202020';
wwv_flow_api.g_varchar2_table(13) := '202020202020202020202020207830323A20636F6D6D656E744A534F4E2E69642C0D0A20202020202020202020202020202020202020207830333A20636F6D6D656E744A534F4E2E706172656E742C0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(14) := '207830343A20636F6D6D656E744A534F4E2E636F6E74656E742C0D0A20202020202020202020202020202020202020207830353A20636F6D6D656E744A534F4E2E66756C6C6E616D652C0D0A20202020202020202020202020202020202020207830363A';
wwv_flow_api.g_varchar2_table(15) := '2027494E53434F4D4D454E54270D0A2020202020202020202020207D2C20200D0A2020202020202020202020207B0D0A20202020202020202020202020202020737563636573733A2066756E6374696F6E282064617461202920207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(16) := '2020202020202020202020202020636F6E736F6C652E6C6F6728636F6D6D656E744A534F4E293B0D0A20202020202020202020202020202020202020207375636365737328636F6D6D656E744A534F4E293B0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(17) := '7D2C0D0A202020202020202020202020202020206572726F723A2066756E6374696F6E28206A715848522C20746578745374617475732C206572726F725468726F776E2029207B0D0A2020202020202020202020202020202020202020617065782E6D65';
wwv_flow_api.g_varchar2_table(18) := '73736167652E616C657274286A715848522E726573706F6E73654A534F4E2E6D657373616765293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D290D0A20202020202020207D2C0D0A0D0A20202020202020202F';
wwv_flow_api.g_varchar2_table(19) := '2F44656C65746520636F6D6D656E740D0A202020202020202064656C657465436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B0D0A2020202020202020202020202F2F636865636B';
wwv_flow_api.g_varchar2_table(20) := '2069662074686520636F6D6D656E74206F72207265706C7920776173207375636365737366756C6C792070726F6365737365640D0A20202020202020202020202076617220697350726F636573735375636365737366756C6C7946696E69686564203D20';
wwv_flow_api.g_varchar2_table(21) := '747275653B0D0A0D0A2020202020202020202020202F2F44656C6574696E67207265706C6965730D0A20202020202020202020202069662028636F6E6669672E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E67436F6D6D656E';
wwv_flow_api.g_varchar2_table(22) := '74576974685265706C69657329207B0D0A20202020202020202020202020202020617065782E7365727665722E706C7567696E202820636F6E6669672E66756E6374696F6E616C69746965732E616A61784964656E7469666965722C207B0D0A20202020';
wwv_flow_api.g_varchar2_table(23) := '2020202020202020202020202020202020202020202020207830313A202744272C0D0A202020202020202020202020202020202020202020202020202020207830323A20636F6D6D656E744A534F4E2E69642C0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(24) := '202020202020202020202020207830333A20636F6D6D656E744A534F4E2E706172656E742C0D0A202020202020202020202020202020202020202020202020202020207830343A20636F6D6D656E744A534F4E2E636F6E74656E742C0D0A202020202020';
wwv_flow_api.g_varchar2_table(25) := '202020202020202020202020202020202020202020207830353A20636F6D6D656E744A534F4E2E66756C6C6E616D652C0D0A202020202020202020202020202020202020202020202020202020207830363A202744454C5245504C494553270D0A202020';
wwv_flow_api.g_varchar2_table(26) := '20202020202020202020202020202020207D2C20200D0A20202020202020202020202020202020202020207B0D0A20202020202020202020202020202020202020202020202020202020737563636573733A2066756E6374696F6E282064617461202920';
wwv_flow_api.g_varchar2_table(27) := '207B0D0A2020202020202020202020202020202020202020202020202020202020202020697350726F636573735375636365737366756C6C7946696E69686564203D20646174612E737563636573733B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(28) := '202020202020202020207D2C0D0A202020202020202020202020202020202020202020202020202020206572726F723A2066756E6374696F6E28206A715848522C20746578745374617475732C206572726F725468726F776E2029207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(29) := '202020202020202020202020202020202020202020202020202020697350726F636573735375636365737366756C6C7946696E69686564203D2066616C73653B0D0A20202020202020202020202020202020202020202020202020202020202020206170';
wwv_flow_api.g_varchar2_table(30) := '65782E6D6573736167652E616C657274286A715848522E726573706F6E73654A534F4E2E6D657373616765293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(31) := '2020207D0D0A0D0A2020202020202020202020202F2F44656C6574696E6720636F6D6D656E740D0A2020202020202020202020206966202821636F6E6669672E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E67436F6D6D656E';
wwv_flow_api.g_varchar2_table(32) := '74576974685265706C69657320262620697350726F636573735375636365737366756C6C7946696E69686564297B0D0A20202020202020202020202020202020617065782E7365727665722E706C7567696E202820636F6E6669672E66756E6374696F6E';
wwv_flow_api.g_varchar2_table(33) := '616C69746965732E616A61784964656E7469666965722C207B0D0A2020202020202020202020202020202020202020202020207830313A202744272C0D0A2020202020202020202020202020202020202020202020207830323A20636F6D6D656E744A53';
wwv_flow_api.g_varchar2_table(34) := '4F4E2E69642C0D0A2020202020202020202020202020202020202020202020207830333A20636F6D6D656E744A534F4E2E706172656E742C0D0A2020202020202020202020202020202020202020202020207830343A20636F6D6D656E744A534F4E2E63';
wwv_flow_api.g_varchar2_table(35) := '6F6E74656E742C0D0A2020202020202020202020202020202020202020202020207830353A20636F6D6D656E744A534F4E2E66756C6C6E616D652C0D0A2020202020202020202020202020202020202020202020207830363A202744454C434F4D4D454E';
wwv_flow_api.g_varchar2_table(36) := '54270D0A202020202020202020202020202020207D2C20200D0A202020202020202020202020202020207B0D0A2020202020202020202020202020202020202020737563636573733A2066756E6374696F6E282064617461202920207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(37) := '20202020202020202020202020202020202020697350726F636573735375636365737366756C6C7946696E69686564203D20646174612E737563636573733B0D0A20202020202020202020202020202020202020207D2C0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(38) := '2020202020202020206572726F723A2066756E6374696F6E28206A715848522C20746578745374617475732C206572726F725468726F776E2029207B0D0A202020202020202020202020202020202020202020202020697350726F636573735375636365';
wwv_flow_api.g_varchar2_table(39) := '737366756C6C7946696E69686564203D2066616C73653B0D0A202020202020202020202020202020202020202020202020617065782E6D6573736167652E616C657274286A715848522E726573706F6E73654A534F4E2E6D657373616765293B0D0A2020';
wwv_flow_api.g_varchar2_table(40) := '2020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2F5570646174696E6720706172656E742049447320746F206E756C6C';
wwv_flow_api.g_varchar2_table(41) := '20696620656E61626C652064656C6574696E6720636F6D6D656E742077697468207265706C6965732064697361626C65640D0A2020202020202020202020206966202821636F6E6669672E66756E6374696F6E616C69746965732E656E61626C6544656C';
wwv_flow_api.g_varchar2_table(42) := '6574696E67436F6D6D656E74576974685265706C69657320262620697350726F636573735375636365737366756C6C7946696E6968656429207B0D0A20202020202020202020202020202020617065782E7365727665722E706C7567696E202820636F6E';
wwv_flow_api.g_varchar2_table(43) := '6669672E66756E6374696F6E616C69746965732E616A61784964656E7469666965722C207B0D0A2020202020202020202020202020202020202020202020207830313A202755272C0D0A2020202020202020202020202020202020202020202020207830';
wwv_flow_api.g_varchar2_table(44) := '323A20636F6D6D656E744A534F4E2E69642C0D0A2020202020202020202020202020202020202020202020207830333A20636F6D6D656E744A534F4E2E706172656E742C0D0A2020202020202020202020202020202020202020202020207830343A2063';
wwv_flow_api.g_varchar2_table(45) := '6F6D6D656E744A534F4E2E636F6E74656E742C0D0A2020202020202020202020202020202020202020202020207830353A20636F6D6D656E744A534F4E2E66756C6C6E616D652C0D0A202020202020202020202020202020202020202020202020783036';
wwv_flow_api.g_varchar2_table(46) := '3A20275550445245504C494553270D0A202020202020202020202020202020207D2C20200D0A202020202020202020202020202020207B0D0A2020202020202020202020202020202020202020737563636573733A2066756E6374696F6E282064617461';
wwv_flow_api.g_varchar2_table(47) := '202920207B0D0A202020202020202020202020202020202020202020202020697350726F636573735375636365737366756C6C7946696E69686564203D20646174612E737563636573733B0D0A20202020202020202020202020202020202020207D2C0D';
wwv_flow_api.g_varchar2_table(48) := '0A20202020202020202020202020202020202020206572726F723A2066756E6374696F6E28206A715848522C20746578745374617475732C206572726F725468726F776E2029207B0D0A2020202020202020202020202020202020202020202020206170';
wwv_flow_api.g_varchar2_table(49) := '65782E6D6573736167652E616C657274286A715848522E726573706F6E73654A534F4E2E6D657373616765293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D290D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(50) := '20207D0D0A0D0A2020202020202020202020202F2F6D616E6970756C61746520444F4D0D0A20202020202020202020202069662028697350726F636573735375636365737366756C6C7946696E6968656429207375636365737328636F6D6D656E744A53';
wwv_flow_api.g_varchar2_table(51) := '4F4E293B0D0A20202020202020207D2C0D0A0D0A20202020202020202F2F557064617465206578697374696E6720636F6D6D656E740D0A2020202020202020707574436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563';
wwv_flow_api.g_varchar2_table(52) := '636573732C206572726F7229207B0D0A0D0A2020202020202020202020202F2F55706461746520636F6D6D656E740D0A202020202020202020202020617065782E7365727665722E706C7567696E202820636F6E6669672E66756E6374696F6E616C6974';
wwv_flow_api.g_varchar2_table(53) := '6965732E616A61784964656E7469666965722C207B0D0A20202020202020202020202020202020202020207830313A202755272C0D0A20202020202020202020202020202020202020207830323A20636F6D6D656E744A534F4E2E69642C0D0A20202020';
wwv_flow_api.g_varchar2_table(54) := '202020202020202020202020202020207830333A20636F6D6D656E744A534F4E2E706172656E742C0D0A20202020202020202020202020202020202020207830343A20636F6D6D656E744A534F4E2E636F6E74656E742C0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(55) := '2020202020202020207830353A20636F6D6D656E744A534F4E2E66756C6C6E616D652C0D0A20202020202020202020202020202020202020207830363A2027555044434F4D4D454E54270D0A2020202020202020202020207D2C20200D0A202020202020';
wwv_flow_api.g_varchar2_table(56) := '2020202020207B0D0A20202020202020202020202020202020737563636573733A2066756E6374696F6E282064617461202920207B0D0A20202020202020202020202020202020202020207375636365737328636F6D6D656E744A534F4E293B0D0A2020';
wwv_flow_api.g_varchar2_table(57) := '20202020202020202020202020207D2C0D0A202020202020202020202020202020206572726F723A2066756E6374696F6E28206A715848522C20746578745374617475732C206572726F725468726F776E2029207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(58) := '20202020202020617065782E6D6573736167652E616C657274286A715848522E726573706F6E73654A534F4E2E6D657373616765293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D293B0D0A0D0A202020202020';
wwv_flow_api.g_varchar2_table(59) := '2020202020202F2F6D616E6970756C61746520444F4D0D0A2020202020202020202020207375636365737328636F6D6D656E744A534F4E293B0D0A20202020202020207D0D0A0D0A202020207D3B0D0A0D0A202020202F2F6A6F696E204A534F4E206F62';
wwv_flow_api.g_varchar2_table(60) := '6A656374730D0A2020202069662028696E697420262620747970656F6620696E6974203D3D202766756E6374696F6E272920696E69742E63616C6C28746869732C20636F6E666967293B0D0A0D0A202020202F2F496E697420726567696F6E0D0A202020';
wwv_flow_api.g_varchar2_table(61) := '20617065782E726567696F6E2E63726561746528726567696F6E49642C207B0D0A2020202020202020747970653A2027617065782D726567696F6E2D636F6D6D656E7473270D0A202020207D293B0D0A0D0A202020202F2F696E697469616C697A652074';
wwv_flow_api.g_varchar2_table(62) := '686520636F6D6D656E74696E6720726567696F6E0D0A202020202428272327202B20726567696F6E4964292E636F6D6D656E747328636667293B0D0A0D0A202020202F2F466978696E67207375626D697420627574746F6E206973737565203A20687474';
wwv_flow_api.g_varchar2_table(63) := '70733A2F2F6769746875622E636F6D2F5669696D612F6A71756572792D636F6D6D656E74732F6973737565732F3134390D0A202020202428272327202B20726567696F6E4964292E66696E6428272E616374696F6E2E6564697427292E61747472282774';
wwv_flow_api.g_varchar2_table(64) := '797065272C27627574746F6E27293B0D0A7D3B0D0A0D0A0D0A2F2F6372656174696E672070696E677320666F7220636F6D6D656E74730D0A434F4D4D454E54532E63726561746550696E67696E676C6973744A534F4E203D2066756E6374696F6E287573';
wwv_flow_api.g_varchar2_table(65) := '657273417272617929207B0D0A20202020766172206C697374203D207B7D3B0D0A0D0A20202020757365727341727261792E666F72456163682866756E6374696F6E286F626A29207B200D0A20202020202020206C6973745B6F626A2E69645D203D206F';
wwv_flow_api.g_varchar2_table(66) := '626A2E66756C6C6E616D653B0D0A202020207D293B0D0A0D0A2020202072657475726E206C6973743B0D0A7D0D0A0D0A2F2F616464696E672070696E677320746F20636F6D6D656E74730D0A434F4D4D454E54532E61646450696E67734A534F4E203D20';
wwv_flow_api.g_varchar2_table(67) := '66756E6374696F6E28757365727341727261792C70696E677329207B0D0A202020207661722070696E6773496E537472696E673B0D0A0D0A20202020757365727341727261792E666F72456163682866756E6374696F6E286F626A29207B0D0A20202020';
wwv_flow_api.g_varchar2_table(68) := '2020202070696E6773496E537472696E67203D20434F4D4D454E54532E67657450696E6773496E537472696E67286F626A2E636F6E74656E74293B0D0A20202020202020206F626A2E70696E6773203D20434F4D4D454E54532E63726561746550696E67';
wwv_flow_api.g_varchar2_table(69) := '696E676C6973744A534F4E2870696E67732E66696C7465722870203D3E2070696E6773496E537472696E672E696E636C7564657328702E69642929293B0D0A202020207D293B0D0A202020200D0A2020202072657475726E20757365727341727261793B';
wwv_flow_api.g_varchar2_table(70) := '0D0A7D0D0A0D0A2F2F67657420616C6C2070696E677320696E20636F6D6D656E7420737472696E670D0A434F4D4D454E54532E67657450696E6773496E537472696E67203D2066756E6374696F6E2873747229207B0D0A20202020636F6E737420726567';
wwv_flow_api.g_varchar2_table(71) := '6578203D202F5B5E405C645D2F673B0D0A2020202072657475726E207374722E7265706C616365416C6C2872656765782C2727292E73706C697428274027292E6D6170284E756D626572293B0D0A7D0D0A0D0A2F2F66696C7465722070696E67696E6720';
wwv_flow_api.g_varchar2_table(72) := '6C6973742064796E616D6963616C6C790D0A434F4D4D454E54532E66696C74657250696E67734C697374203D2066756E6374696F6E286C6973742C6E616D6529207B0D0A20202020766172206E203D206E657720526567457870286E616D652E746F5570';
wwv_flow_api.g_varchar2_table(73) := '706572436173652829293B0D0A2020202072657475726E206C6973742E66696C746572286C203D3E206C2E66756C6C6E616D652E746F55707065724361736528292E6D61746368286E29293B0D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(39836974059989375699)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/script.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2866756E6374696F6E2028666163746F727929207B0D0A2020202069662028747970656F6620646566696E65203D3D3D202766756E6374696F6E2720262620646566696E652E616D6429207B0D0A2020202020202F2F20414D442E205265676973746572';
wwv_flow_api.g_varchar2_table(2) := '20617320616E20616E6F6E796D6F7573206D6F64756C652E0D0A202020202020646566696E65285B276A7175657279275D2C20666163746F7279293B0D0A202020207D20656C73652069662028747970656F66206D6F64756C65203D3D3D20226F626A65';
wwv_flow_api.g_varchar2_table(3) := '637422202626206D6F64756C652E6578706F72747329207B0D0A2020202020207661722024203D207265717569726528276A717565727927293B0D0A2020202020206D6F64756C652E6578706F727473203D20666163746F72792824293B0D0A20202020';
wwv_flow_api.g_varchar2_table(4) := '7D20656C7365207B0D0A2020202020202F2F2042726F7773657220676C6F62616C730D0A202020202020666163746F7279286A5175657279293B0D0A202020207D0D0A20207D2866756E6374696F6E20286A517565727929207B0D0A20200D0A20202F2A';
wwv_flow_api.g_varchar2_table(5) := '210D0A2020202A206A51756572792E74657874636F6D706C6574650D0A2020202A0D0A2020202A205265706F7369746F72793A2068747470733A2F2F6769746875622E636F6D2F79756B752D742F6A71756572792D74657874636F6D706C6574650D0A20';
wwv_flow_api.g_varchar2_table(6) := '20202A204C6963656E73653A202020204D4954202868747470733A2F2F6769746875622E636F6D2F79756B752D742F6A71756572792D74657874636F6D706C6574652F626C6F622F6D61737465722F4C4943454E5345290D0A2020202A20417574686F72';
wwv_flow_api.g_varchar2_table(7) := '3A202020202059756B752054616B6168617368690D0A2020202A2F0D0A20200D0A202069662028747970656F66206A5175657279203D3D3D2027756E646566696E65642729207B0D0A202020207468726F77206E6577204572726F7228276A5175657279';
wwv_flow_api.g_varchar2_table(8) := '2E74657874636F6D706C657465207265717569726573206A517565727927293B0D0A20207D0D0A20200D0A20202B66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A20202020766172207761726E203D20';
wwv_flow_api.g_varchar2_table(9) := '66756E6374696F6E20286D65737361676529207B0D0A20202020202069662028636F6E736F6C652E7761726E29207B20636F6E736F6C652E7761726E286D657373616765293B207D0D0A202020207D3B0D0A20200D0A20202020766172206964203D2031';
wwv_flow_api.g_varchar2_table(10) := '3B0D0A20200D0A20202020242E666E2E74657874636F6D706C657465203D2066756E6374696F6E2028737472617465676965732C206F7074696F6E29207B0D0A2020202020207661722061726773203D2041727261792E70726F746F747970652E736C69';
wwv_flow_api.g_varchar2_table(11) := '63652E63616C6C28617267756D656E7473293B0D0A20202020202072657475726E20746869732E656163682866756E6374696F6E202829207B0D0A20202020202020207661722073656C66203D20746869733B0D0A202020202020202076617220247468';
wwv_flow_api.g_varchar2_table(12) := '6973203D20242874686973293B0D0A202020202020202076617220636F6D706C65746572203D2024746869732E64617461282774657874436F6D706C65746527293B0D0A20202020202020206966202821636F6D706C6574657229207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(13) := '20202020206F7074696F6E207C7C20286F7074696F6E203D207B7D293B0D0A202020202020202020206F7074696F6E2E5F6F6964203D2069642B2B3B20202F2F20756E69717565206F626A6563742069640D0A20202020202020202020636F6D706C6574';
wwv_flow_api.g_varchar2_table(14) := '6572203D206E657720242E666E2E74657874636F6D706C6574652E436F6D706C6574657228746869732C206F7074696F6E293B0D0A2020202020202020202024746869732E64617461282774657874436F6D706C657465272C20636F6D706C6574657229';
wwv_flow_api.g_varchar2_table(15) := '3B0D0A20202020202020207D0D0A202020202020202069662028747970656F662073747261746567696573203D3D3D2027737472696E672729207B0D0A202020202020202020206966202821636F6D706C65746572292072657475726E3B0D0A20202020';
wwv_flow_api.g_varchar2_table(16) := '202020202020617267732E736869667428290D0A20202020202020202020636F6D706C657465725B737472617465676965735D2E6170706C7928636F6D706C657465722C2061726773293B0D0A2020202020202020202069662028737472617465676965';
wwv_flow_api.g_varchar2_table(17) := '73203D3D3D202764657374726F792729207B0D0A20202020202020202020202024746869732E72656D6F766544617461282774657874436F6D706C65746527293B0D0A202020202020202020207D0D0A20202020202020207D20656C7365207B0D0A2020';
wwv_flow_api.g_varchar2_table(18) := '20202020202020202F2F20466F72206261636B7761726420636F6D7061746962696C6974792E0D0A202020202020202020202F2F20544F444F3A2052656D6F76652061742076302E340D0A20202020202020202020242E65616368287374726174656769';
wwv_flow_api.g_varchar2_table(19) := '65732C2066756E6374696F6E20286F626A29207B0D0A202020202020202020202020242E65616368285B27686561646572272C2027666F6F746572272C2027706C6163656D656E74272C20276D6178436F756E74275D2C2066756E6374696F6E20286E61';
wwv_flow_api.g_varchar2_table(20) := '6D6529207B0D0A2020202020202020202020202020696620286F626A5B6E616D655D29207B0D0A20202020202020202020202020202020636F6D706C657465722E6F7074696F6E5B6E616D655D203D206F626A5B6E616D655D3B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(21) := '20202020202020207761726E286E616D65202B20276173206120737472617465677920706172616D20697320646570726563617465642E20557365206F7074696F6E2E27293B0D0A2020202020202020202020202020202064656C657465206F626A5B6E';
wwv_flow_api.g_varchar2_table(22) := '616D655D3B0D0A20202020202020202020202020207D0D0A2020202020202020202020207D293B0D0A202020202020202020207D293B0D0A20202020202020202020636F6D706C657465722E726567697374657228242E666E2E74657874636F6D706C65';
wwv_flow_api.g_varchar2_table(23) := '74652E53747261746567792E706172736528737472617465676965732C207B0D0A202020202020202020202020656C3A2073656C662C0D0A20202020202020202020202024656C3A2024746869730D0A202020202020202020207D29293B0D0A20202020';
wwv_flow_api.g_varchar2_table(24) := '202020207D0D0A2020202020207D293B0D0A202020207D3B0D0A20200D0A20207D286A5175657279293B0D0A20200D0A20202B66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A202020202F2F20457863';
wwv_flow_api.g_varchar2_table(25) := '6C757369766520657865637574696F6E20636F6E74726F6C207574696C6974792E0D0A202020202F2F0D0A202020202F2F2066756E63202D205468652066756E6374696F6E20746F206265206C6F636B65642E2049742069732065786563757465642077';
wwv_flow_api.g_varchar2_table(26) := '69746820612066756E6374696F6E206E616D65640D0A202020202F2F20202020202020206066726565602061732074686520666972737420617267756D656E742E204F6E63652069742069732063616C6C65642C206164646974696F6E616C0D0A202020';
wwv_flow_api.g_varchar2_table(27) := '202F2F2020202020202020657865637574696F6E206172652069676E6F72656420756E74696C20746865206672656520697320696E766F6B65642E205468656E20746865206C6173740D0A202020202F2F202020202020202069676E6F72656420657865';
wwv_flow_api.g_varchar2_table(28) := '637574696F6E2077696C6C206265207265706C6179656420696D6D6564696174656C792E0D0A202020202F2F0D0A202020202F2F204578616D706C65730D0A202020202F2F0D0A202020202F2F202020766172206C6F636B656446756E63203D206C6F63';
wwv_flow_api.g_varchar2_table(29) := '6B2866756E6374696F6E20286672656529207B0D0A202020202F2F202020202073657454696D656F75742866756E6374696F6E207B206672656528293B207D2C2031303030293B202F2F2049742077696C6C206265206672656520696E2031207365632E';
wwv_flow_api.g_varchar2_table(30) := '0D0A202020202F2F2020202020636F6E736F6C652E6C6F67282748656C6C6F2C20776F726C6427293B0D0A202020202F2F2020207D293B0D0A202020202F2F2020206C6F636B656446756E6328293B20202F2F203D3E202748656C6C6F2C20776F726C64';
wwv_flow_api.g_varchar2_table(31) := '270D0A202020202F2F2020206C6F636B656446756E6328293B20202F2F206E6F6E650D0A202020202F2F2020206C6F636B656446756E6328293B20202F2F206E6F6E650D0A202020202F2F2020202F2F2031207365632070617374207468656E0D0A2020';
wwv_flow_api.g_varchar2_table(32) := '20202F2F2020202F2F203D3E202748656C6C6F2C20776F726C64270D0A202020202F2F2020206C6F636B656446756E6328293B20202F2F203D3E202748656C6C6F2C20776F726C64270D0A202020202F2F2020206C6F636B656446756E6328293B20202F';
wwv_flow_api.g_varchar2_table(33) := '2F206E6F6E650D0A202020202F2F0D0A202020202F2F2052657475726E73206120777261707065642066756E6374696F6E2E0D0A20202020766172206C6F636B203D2066756E6374696F6E202866756E6329207B0D0A202020202020766172206C6F636B';
wwv_flow_api.g_varchar2_table(34) := '65642C2071756575656441726773546F5265706C61793B0D0A20200D0A20202020202072657475726E2066756E6374696F6E202829207B0D0A20202020202020202F2F20436F6E7665727420617267756D656E747320696E746F2061207265616C206172';
wwv_flow_api.g_varchar2_table(35) := '7261792E0D0A20202020202020207661722061726773203D2041727261792E70726F746F747970652E736C6963652E63616C6C28617267756D656E7473293B0D0A2020202020202020696620286C6F636B656429207B0D0A202020202020202020202F2F';
wwv_flow_api.g_varchar2_table(36) := '204B656570206120636F7079206F66207468697320617267756D656E74206C69737420746F207265706C6179206C617465722E0D0A202020202020202020202F2F204F4B20746F206F766572777269746520612070726576696F75732076616C75652062';
wwv_flow_api.g_varchar2_table(37) := '656361757365207765206F6E6C79207265706C61790D0A202020202020202020202F2F20746865206C617374206F6E652E0D0A2020202020202020202071756575656441726773546F5265706C6179203D20617267733B0D0A2020202020202020202072';
wwv_flow_api.g_varchar2_table(38) := '657475726E3B0D0A20202020202020207D0D0A20202020202020206C6F636B6564203D20747275653B0D0A20202020202020207661722073656C66203D20746869733B0D0A2020202020202020617267732E756E73686966742866756E6374696F6E2072';
wwv_flow_api.g_varchar2_table(39) := '65706C61794F72467265652829207B0D0A202020202020202020206966202871756575656441726773546F5265706C617929207B0D0A2020202020202020202020202F2F204F7468657220726571756573742873292061727269766564207768696C6520';
wwv_flow_api.g_varchar2_table(40) := '77652077657265206C6F636B65642E0D0A2020202020202020202020202F2F204E6F77207468617420746865206C6F636B206973206265636F6D696E6720617661696C61626C652C207265706C61790D0A2020202020202020202020202F2F2074686520';
wwv_flow_api.g_varchar2_table(41) := '6C6174657374207375636820726571756573742C207468656E2063616C6C206261636B206865726520746F0D0A2020202020202020202020202F2F20756E6C6F636B20286F72207265706C617920616E6F74686572207265717565737420746861742061';
wwv_flow_api.g_varchar2_table(42) := '7272697665640D0A2020202020202020202020202F2F207768696C652074686973206F6E652077617320696E20666C69676874292E0D0A202020202020202020202020766172207265706C617941726773203D2071756575656441726773546F5265706C';
wwv_flow_api.g_varchar2_table(43) := '61793B0D0A20202020202020202020202071756575656441726773546F5265706C6179203D20756E646566696E65643B0D0A2020202020202020202020207265706C6179417267732E756E7368696674287265706C61794F7246726565293B0D0A202020';
wwv_flow_api.g_varchar2_table(44) := '20202020202020202066756E632E6170706C792873656C662C207265706C617941726773293B0D0A202020202020202020207D20656C7365207B0D0A2020202020202020202020206C6F636B6564203D2066616C73653B0D0A202020202020202020207D';
wwv_flow_api.g_varchar2_table(45) := '0D0A20202020202020207D293B0D0A202020202020202066756E632E6170706C7928746869732C2061726773293B0D0A2020202020207D3B0D0A202020207D3B0D0A20200D0A20202020766172206973537472696E67203D2066756E6374696F6E20286F';
wwv_flow_api.g_varchar2_table(46) := '626A29207B0D0A20202020202072657475726E204F626A6563742E70726F746F747970652E746F537472696E672E63616C6C286F626A29203D3D3D20275B6F626A65637420537472696E675D273B0D0A202020207D3B0D0A20200D0A2020202076617220';
wwv_flow_api.g_varchar2_table(47) := '756E697175654964203D20303B0D0A2020202076617220696E697469616C697A6564456469746F7273203D205B5D3B0D0A20200D0A2020202066756E6374696F6E20436F6D706C6574657228656C656D656E742C206F7074696F6E29207B0D0A20202020';
wwv_flow_api.g_varchar2_table(48) := '2020746869732E24656C20202020202020203D202428656C656D656E74293B0D0A202020202020746869732E69642020202020202020203D202774657874636F6D706C65746527202B20756E6971756549642B2B3B0D0A202020202020746869732E7374';
wwv_flow_api.g_varchar2_table(49) := '7261746567696573203D205B5D3B0D0A202020202020746869732E76696577732020202020203D205B5D3B0D0A202020202020746869732E6F7074696F6E20202020203D20242E657874656E64287B7D2C20436F6D706C657465722E64656661756C7473';
wwv_flow_api.g_varchar2_table(50) := '2C206F7074696F6E293B0D0A20200D0A2020202020206966202821746869732E24656C2E69732827696E7075745B747970653D746578745D27292026262021746869732E24656C2E69732827696E7075745B747970653D7365617263685D272920262620';
wwv_flow_api.g_varchar2_table(51) := '21746869732E24656C2E69732827746578746172656127292026262021656C656D656E742E6973436F6E74656E744564697461626C6520262620656C656D656E742E636F6E74656E744564697461626C6520213D2027747275652729207B0D0A20202020';
wwv_flow_api.g_varchar2_table(52) := '202020207468726F77206E6577204572726F72282774657874636F6D706C657465206D7573742062652063616C6C6564206F6E2061205465787461726561206F72206120436F6E74656E744564697461626C652E27293B0D0A2020202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(53) := '0D0A2020202020202F2F20757365206F776E6572446F63756D656E7420746F2066697820696672616D65202F204945206973737565730D0A20202020202069662028656C656D656E74203D3D3D20656C656D656E742E6F776E6572446F63756D656E742E';
wwv_flow_api.g_varchar2_table(54) := '616374697665456C656D656E7429207B0D0A20202020202020202F2F20656C656D656E742068617320616C7265616479206265656E20666F63757365642E20496E697469616C697A652076696577206F626A6563747320696D6D6564696174656C792E0D';
wwv_flow_api.g_varchar2_table(55) := '0A2020202020202020746869732E696E697469616C697A6528290D0A2020202020207D20656C7365207B0D0A20202020202020202F2F20496E697469616C697A652076696577206F626A65637473206C617A696C792E0D0A202020202020202076617220';
wwv_flow_api.g_varchar2_table(56) := '73656C66203D20746869733B0D0A2020202020202020746869732E24656C2E6F6E652827666F6375732E27202B20746869732E69642C2066756E6374696F6E202829207B2073656C662E696E697469616C697A6528293B207D293B0D0A20200D0A202020';
wwv_flow_api.g_varchar2_table(57) := '20202020202F2F205370656369616C2068616E646C696E6720666F7220434B456469746F723A206C617A7920696E6974206F6E20696E7374616E6365206C6F61640D0A2020202020202020696620282821746869732E6F7074696F6E2E61646170746572';
wwv_flow_api.g_varchar2_table(58) := '207C7C20746869732E6F7074696F6E2E61646170746572203D3D2027434B456469746F72272920262620747970656F6620434B454449544F5220213D2027756E646566696E6564272026262028746869732E24656C2E6973282774657874617265612729';
wwv_flow_api.g_varchar2_table(59) := '2929207B0D0A20202020202020202020434B454449544F522E6F6E2822696E7374616E63655265616479222C2066756E6374696F6E286576656E7429207B202F2F466F72206D756C7469706C6520636B656469746F7273206F6E206F6E6520706167653A';
wwv_flow_api.g_varchar2_table(60) := '2074686973206E6565647320746F20626520657865637574656420656163682074696D65206120636B656469746F722D696E7374616E63652069732072656164792E0D0A20200D0A202020202020202020202020696628242E696E417272617928657665';
wwv_flow_api.g_varchar2_table(61) := '6E742E656469746F722E69642C20696E697469616C697A6564456469746F727329203D3D202D3129207B202F2F466F72206D756C7469706C6520636B656469746F7273206F6E206F6E6520706167653A20666F6375732D6576656E7468616E646C657220';
wwv_flow_api.g_varchar2_table(62) := '73686F756C64206F6E6C79206265206164646564206F6E636520666F7220657665727920656469746F722E0D0A2020202020202020202020202020696E697469616C697A6564456469746F72732E70757368286576656E742E656469746F722E6964293B';
wwv_flow_api.g_varchar2_table(63) := '0D0A20202020202020202020202020200D0A20202020202020202020202020206576656E742E656469746F722E6F6E2822666F637573222C2066756E6374696F6E286576656E743229207B0D0A2020202020202020202020202020202020202F2F726570';
wwv_flow_api.g_varchar2_table(64) := '6C6163652074686520656C656D656E7420776974682074686520496672616D6520656C656D656E7420616E6420666C616720697420617320434B456469746F720D0A20202020202020202020202020202020202073656C662E24656C203D202428657665';
wwv_flow_api.g_varchar2_table(65) := '6E742E656469746F722E6564697461626C6528292E24293B0D0A202020202020202020202020202020202020696620282173656C662E6F7074696F6E2E6164617074657229207B0D0A2020202020202020202020202020202020202020202073656C662E';
wwv_flow_api.g_varchar2_table(66) := '6F7074696F6E2E61646170746572203D20242E666E2E74657874636F6D706C6574655B27434B456469746F72275D3B0D0A2020202020202020202020202020202020207D0D0A20202020202020202020202020202020202073656C662E6F7074696F6E2E';
wwv_flow_api.g_varchar2_table(67) := '636B656469746F725F696E7374616E6365203D206576656E742E656469746F723B202F2F466F72206D756C7469706C6520636B656469746F7273206F6E206F6E6520706167653A20696E20746865206F6C6420636F6465207468697320776173206E6F74';
wwv_flow_api.g_varchar2_table(68) := '206578656375746564207768656E20616461707465722077617320616C72656164207365742E20536F207765207765726520414C5741595320776F726B696E6720776974682074686520464952535420696E7374616E63652E0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(69) := '202020202020202020202073656C662E696E697469616C697A6528293B0D0A20202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D0D0A';
wwv_flow_api.g_varchar2_table(70) := '202020207D0D0A20200D0A20202020436F6D706C657465722E64656661756C7473203D207B0D0A202020202020617070656E64546F3A2027626F6479272C0D0A202020202020636C6173734E616D653A2027272C20202F2F206465707265636174656420';
wwv_flow_api.g_varchar2_table(71) := '6F7074696F6E0D0A20202020202064726F70646F776E436C6173734E616D653A202764726F70646F776E2D6D656E752074657874636F6D706C6574652D64726F70646F776E272C0D0A2020202020206D6178436F756E743A2031302C0D0A202020202020';
wwv_flow_api.g_varchar2_table(72) := '7A496E6465783A2027313030272C0D0A2020202020207269676874456467654F66667365743A2033300D0A202020207D3B0D0A20200D0A20202020242E657874656E6428436F6D706C657465722E70726F746F747970652C207B0D0A2020202020202F2F';
wwv_flow_api.g_varchar2_table(73) := '205075626C69632070726F706572746965730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A20202020202069643A2020202020202020206E756C6C2C0D0A2020202020206F7074696F6E3A20202020206E756C6C2C';
wwv_flow_api.g_varchar2_table(74) := '0D0A202020202020737472617465676965733A206E756C6C2C0D0A202020202020616461707465723A202020206E756C6C2C0D0A20202020202064726F70646F776E3A2020206E756C6C2C0D0A20202020202024656C3A20202020202020206E756C6C2C';
wwv_flow_api.g_varchar2_table(75) := '0D0A20202020202024696672616D653A202020206E756C6C2C0D0A20200D0A2020202020202F2F205075626C6963206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A202020202020696E697469616C697A';
wwv_flow_api.g_varchar2_table(76) := '653A2066756E6374696F6E202829207B0D0A202020202020202076617220656C656D656E74203D20746869732E24656C2E6765742830293B0D0A20202020202020200D0A20202020202020202F2F20636865636B2069662077652061726520696E20616E';
wwv_flow_api.g_varchar2_table(77) := '20696672616D650D0A20202020202020202F2F207765206E65656420746F20616C74657220706F736974696F6E696E67206C6F676963206966207573696E6720616E20696672616D650D0A202020202020202069662028746869732E24656C2E70726F70';
wwv_flow_api.g_varchar2_table(78) := '28276F776E6572446F63756D656E74272920213D3D20646F63756D656E742026262077696E646F772E6672616D65732E6C656E67746829207B0D0A20202020202020202020666F72202876617220696672616D65496E646578203D20303B20696672616D';
wwv_flow_api.g_varchar2_table(79) := '65496E646578203C2077696E646F772E6672616D65732E6C656E6774683B20696672616D65496E6465782B2B29207B0D0A20202020202020202020202069662028746869732E24656C2E70726F7028276F776E6572446F63756D656E742729203D3D3D20';
wwv_flow_api.g_varchar2_table(80) := '77696E646F772E6672616D65735B696672616D65496E6465785D2E646F63756D656E7429207B0D0A2020202020202020202020202020746869732E24696672616D65203D20242877696E646F772E6672616D65735B696672616D65496E6465785D2E6672';
wwv_flow_api.g_varchar2_table(81) := '616D65456C656D656E74293B0D0A2020202020202020202020202020627265616B3B0D0A2020202020202020202020207D0D0A202020202020202020207D0D0A20202020202020207D0D0A20202020202020200D0A20202020202020200D0A2020202020';
wwv_flow_api.g_varchar2_table(82) := '2020202F2F20496E697469616C697A652076696577206F626A656374732E0D0A2020202020202020746869732E64726F70646F776E203D206E657720242E666E2E74657874636F6D706C6574652E44726F70646F776E28656C656D656E742C2074686973';
wwv_flow_api.g_varchar2_table(83) := '2C20746869732E6F7074696F6E293B0D0A202020202020202076617220416461707465722C20766965774E616D653B0D0A202020202020202069662028746869732E6F7074696F6E2E6164617074657229207B0D0A202020202020202020204164617074';
wwv_flow_api.g_varchar2_table(84) := '6572203D20746869732E6F7074696F6E2E616461707465723B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202069662028746869732E24656C2E6973282774657874617265612729207C7C20746869732E24656C2E6973282769';
wwv_flow_api.g_varchar2_table(85) := '6E7075745B747970653D746578745D2729207C7C20746869732E24656C2E69732827696E7075745B747970653D7365617263685D272929207B0D0A202020202020202020202020766965774E616D65203D20747970656F6620656C656D656E742E73656C';
wwv_flow_api.g_varchar2_table(86) := '656374696F6E456E64203D3D3D20276E756D62657227203F2027546578746172656127203A202749455465787461726561273B0D0A202020202020202020207D20656C7365207B0D0A202020202020202020202020766965774E616D65203D2027436F6E';
wwv_flow_api.g_varchar2_table(87) := '74656E744564697461626C65273B0D0A202020202020202020207D0D0A2020202020202020202041646170746572203D20242E666E2E74657874636F6D706C6574655B766965774E616D655D3B0D0A20202020202020207D0D0A20202020202020207468';
wwv_flow_api.g_varchar2_table(88) := '69732E61646170746572203D206E6577204164617074657228656C656D656E742C20746869732C20746869732E6F7074696F6E293B0D0A2020202020207D2C0D0A20200D0A20202020202064657374726F793A2066756E6374696F6E202829207B0D0A20';
wwv_flow_api.g_varchar2_table(89) := '20202020202020746869732E24656C2E6F666628272E27202B20746869732E6964293B0D0A202020202020202069662028746869732E6164617074657229207B0D0A20202020202020202020746869732E616461707465722E64657374726F7928293B0D';
wwv_flow_api.g_varchar2_table(90) := '0A20202020202020207D0D0A202020202020202069662028746869732E64726F70646F776E29207B0D0A20202020202020202020746869732E64726F70646F776E2E64657374726F7928293B0D0A20202020202020207D0D0A2020202020202020746869';
wwv_flow_api.g_varchar2_table(91) := '732E24656C203D20746869732E61646170746572203D20746869732E64726F70646F776E203D206E756C6C3B0D0A2020202020207D2C0D0A20200D0A202020202020646561637469766174653A2066756E6374696F6E202829207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(92) := '2069662028746869732E64726F70646F776E29207B0D0A20202020202020202020746869732E64726F70646F776E2E6465616374697661746528293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020202F2F20496E766F';
wwv_flow_api.g_varchar2_table(93) := '6B652074657874636F6D706C6574652E0D0A202020202020747269676765723A2066756E6374696F6E2028746578742C20736B6970556E6368616E6765645465726D29207B0D0A20202020202020206966202821746869732E64726F70646F776E29207B';
wwv_flow_api.g_varchar2_table(94) := '20746869732E696E697469616C697A6528293B207D0D0A20202020202020207465787420213D206E756C6C207C7C202874657874203D20746869732E616461707465722E6765745465787446726F6D48656164546F43617265742829293B0D0A20202020';
wwv_flow_api.g_varchar2_table(95) := '20202020766172207365617263685175657279203D20746869732E5F6578747261637453656172636851756572792874657874293B0D0A20202020202020206966202873656172636851756572792E6C656E67746829207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(96) := '766172207465726D203D2073656172636851756572795B315D3B0D0A202020202020202020202F2F2049676E6F72652073686966742D6B65792C206374726C2D6B657920616E6420736F206F6E2E0D0A2020202020202020202069662028736B6970556E';
wwv_flow_api.g_varchar2_table(97) := '6368616E6765645465726D20262620746869732E5F7465726D203D3D3D207465726D202626207465726D20213D3D20222229207B2072657475726E3B207D0D0A20202020202020202020746869732E5F7465726D203D207465726D3B0D0A202020202020';
wwv_flow_api.g_varchar2_table(98) := '20202020746869732E5F7365617263682E6170706C7928746869732C207365617263685175657279293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020746869732E5F7465726D203D206E756C6C3B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(99) := '2020746869732E64726F70646F776E2E6465616374697661746528293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A202020202020666972653A2066756E6374696F6E20286576656E744E616D6529207B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(100) := '7661722061726773203D2041727261792E70726F746F747970652E736C6963652E63616C6C28617267756D656E74732C2031293B0D0A2020202020202020746869732E24656C2E74726967676572286576656E744E616D652C2061726773293B0D0A2020';
wwv_flow_api.g_varchar2_table(101) := '20202020202072657475726E20746869733B0D0A2020202020207D2C0D0A20200D0A20202020202072656769737465723A2066756E6374696F6E20287374726174656769657329207B0D0A202020202020202041727261792E70726F746F747970652E70';
wwv_flow_api.g_varchar2_table(102) := '7573682E6170706C7928746869732E737472617465676965732C2073747261746567696573293B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F20496E73657274207468652076616C756520696E746F206164617074657220766965772E20';
wwv_flow_api.g_varchar2_table(103) := '49742069732063616C6C6564207768656E207468652064726F70646F776E20697320636C69636B65640D0A2020202020202F2F206F722073656C65637465642E0D0A2020202020202F2F0D0A2020202020202F2F2076616C7565202020202D2054686520';
wwv_flow_api.g_varchar2_table(104) := '73656C656374656420656C656D656E74206F66207468652061727261792063616C6C6261636B65642066726F6D207365617263682066756E632E0D0A2020202020202F2F207374726174656779202D20546865205374726174656779206F626A6563742E';
wwv_flow_api.g_varchar2_table(105) := '0D0A2020202020202F2F206520202020202020202D20436C69636B206F72206B6579646F776E206576656E74206F626A6563742E0D0A20202020202073656C6563743A2066756E6374696F6E202876616C75652C2073747261746567792C206529207B0D';
wwv_flow_api.g_varchar2_table(106) := '0A2020202020202020746869732E5F7465726D203D206E756C6C3B0D0A2020202020202020746869732E616461707465722E73656C6563742876616C75652C2073747261746567792C2065293B0D0A2020202020202020746869732E6669726528276368';
wwv_flow_api.g_varchar2_table(107) := '616E676527292E66697265282774657874436F6D706C6574653A73656C656374272C2076616C75652C207374726174656779293B0D0A2020202020202020746869732E616461707465722E666F63757328293B0D0A2020202020207D2C0D0A20200D0A20';
wwv_flow_api.g_varchar2_table(108) := '20202020202F2F20507269766174652070726F706572746965730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020205F636C65617241744E6578743A20747275652C0D0A2020202020205F7465726D3A';
wwv_flow_api.g_varchar2_table(109) := '20202020202020206E756C6C2C0D0A20200D0A2020202020202F2F2050726976617465206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020202F2F2050617273652074686520676976656E20';
wwv_flow_api.g_varchar2_table(110) := '7465787420616E64206578747261637420746865206669727374206D61746368696E672073747261746567792E0D0A2020202020202F2F0D0A2020202020202F2F2052657475726E7320616E20617272617920696E636C7564696E672074686520737472';
wwv_flow_api.g_varchar2_table(111) := '61746567792C20746865207175657279207465726D20616E6420746865206D617463680D0A2020202020202F2F206F626A656374206966207468652074657874206D61746368657320616E2073747261746567793B206F74686572776973652072657475';
wwv_flow_api.g_varchar2_table(112) := '726E7320616E20656D7074792061727261792E0D0A2020202020205F6578747261637453656172636851756572793A2066756E6374696F6E20287465787429207B0D0A2020202020202020666F7220287661722069203D20303B2069203C20746869732E';
wwv_flow_api.g_varchar2_table(113) := '737472617465676965732E6C656E6774683B20692B2B29207B0D0A20202020202020202020766172207374726174656779203D20746869732E737472617465676965735B695D3B0D0A2020202020202020202076617220636F6E74657874203D20737472';
wwv_flow_api.g_varchar2_table(114) := '61746567792E636F6E746578742874657874293B0D0A2020202020202020202069662028636F6E74657874207C7C20636F6E74657874203D3D3D20272729207B0D0A202020202020202020202020766172206D61746368526567657870203D20242E6973';
wwv_flow_api.g_varchar2_table(115) := '46756E6374696F6E2873747261746567792E6D6174636829203F2073747261746567792E6D61746368287465787429203A2073747261746567792E6D617463683B0D0A202020202020202020202020696620286973537472696E6728636F6E7465787429';
wwv_flow_api.g_varchar2_table(116) := '29207B2074657874203D20636F6E746578743B207D0D0A202020202020202020202020766172206D61746368203D20746578742E6D61746368286D61746368526567657870293B0D0A202020202020202020202020696620286D6174636829207B207265';
wwv_flow_api.g_varchar2_table(117) := '7475726E205B73747261746567792C206D617463685B73747261746567792E696E6465785D2C206D617463685D3B207D0D0A202020202020202020207D0D0A20202020202020207D0D0A202020202020202072657475726E205B5D0D0A2020202020207D';
wwv_flow_api.g_varchar2_table(118) := '2C0D0A20200D0A2020202020202F2F2043616C6C2074686520736561726368206D6574686F64206F662073656C65637465642073747261746567792E2E0D0A2020202020205F7365617263683A206C6F636B2866756E6374696F6E2028667265652C2073';
wwv_flow_api.g_varchar2_table(119) := '747261746567792C207465726D2C206D6174636829207B0D0A20202020202020207661722073656C66203D20746869733B0D0A202020202020202073747261746567792E736561726368287465726D2C2066756E6374696F6E2028646174612C20737469';
wwv_flow_api.g_varchar2_table(120) := '6C6C536561726368696E6729207B0D0A20202020202020202020696620282173656C662E64726F70646F776E2E73686F776E29207B0D0A20202020202020202020202073656C662E64726F70646F776E2E616374697661746528293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(121) := '202020207D0D0A202020202020202020206966202873656C662E5F636C65617241744E65787429207B0D0A2020202020202020202020202F2F205468652066697273742063616C6C6261636B20696E207468652063757272656E74206C6F636B2E0D0A20';
wwv_flow_api.g_varchar2_table(122) := '202020202020202020202073656C662E64726F70646F776E2E636C65617228293B0D0A20202020202020202020202073656C662E5F636C65617241744E657874203D2066616C73653B0D0A202020202020202020207D0D0A202020202020202020207365';
wwv_flow_api.g_varchar2_table(123) := '6C662E64726F70646F776E2E736574506F736974696F6E2873656C662E616461707465722E6765744361726574506F736974696F6E2829293B0D0A2020202020202020202073656C662E64726F70646F776E2E72656E6465722873656C662E5F7A697028';
wwv_flow_api.g_varchar2_table(124) := '646174612C2073747261746567792C207465726D29293B0D0A2020202020202020202069662028217374696C6C536561726368696E6729207B0D0A2020202020202020202020202F2F20546865206C6173742063616C6C6261636B20696E207468652063';
wwv_flow_api.g_varchar2_table(125) := '757272656E74206C6F636B2E0D0A2020202020202020202020206672656528293B0D0A20202020202020202020202073656C662E5F636C65617241744E657874203D20747275653B202F2F2043616C6C2064726F70646F776E2E636C6561722061742074';
wwv_flow_api.g_varchar2_table(126) := '6865206E6578742074696D652E0D0A202020202020202020207D0D0A20202020202020207D2C206D61746368293B0D0A2020202020207D292C0D0A20200D0A2020202020202F2F204275696C64206120706172616D6574657220666F722044726F70646F';
wwv_flow_api.g_varchar2_table(127) := '776E2372656E6465722E0D0A2020202020202F2F0D0A2020202020202F2F204578616D706C65730D0A2020202020202F2F0D0A2020202020202F2F2020746869732E5F7A6970285B2761272C202762275D2C20277327293B0D0A2020202020202F2F2020';
wwv_flow_api.g_varchar2_table(128) := '2F2F3D3E205B7B2076616C75653A202761272C2073747261746567793A20277327207D2C207B2076616C75653A202762272C2073747261746567793A20277327207D5D0D0A2020202020205F7A69703A2066756E6374696F6E2028646174612C20737472';
wwv_flow_api.g_varchar2_table(129) := '61746567792C207465726D29207B0D0A202020202020202072657475726E20242E6D617028646174612C2066756E6374696F6E202876616C756529207B0D0A2020202020202020202072657475726E207B2076616C75653A2076616C75652C2073747261';
wwv_flow_api.g_varchar2_table(130) := '746567793A2073747261746567792C207465726D3A207465726D207D3B0D0A20202020202020207D293B0D0A2020202020207D0D0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E436F6D706C65746572203D20';
wwv_flow_api.g_varchar2_table(131) := '436F6D706C657465723B0D0A20207D286A5175657279293B0D0A20200D0A20202B66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A20202020766172202477696E646F77203D20242877696E646F77293B';
wwv_flow_api.g_varchar2_table(132) := '0D0A20200D0A2020202076617220696E636C756465203D2066756E6374696F6E20287A6970706564446174612C20646174756D29207B0D0A20202020202076617220692C20656C656D3B0D0A20202020202076617220696450726F7065727479203D2064';
wwv_flow_api.g_varchar2_table(133) := '6174756D2E73747261746567792E696450726F70657274790D0A202020202020666F72202869203D20303B2069203C207A6970706564446174612E6C656E6774683B20692B2B29207B0D0A2020202020202020656C656D203D207A697070656444617461';
wwv_flow_api.g_varchar2_table(134) := '5B695D3B0D0A202020202020202069662028656C656D2E737472617465677920213D3D20646174756D2E73747261746567792920636F6E74696E75653B0D0A202020202020202069662028696450726F706572747929207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(135) := '69662028656C656D2E76616C75655B696450726F70657274795D203D3D3D20646174756D2E76616C75655B696450726F70657274795D292072657475726E20747275653B0D0A20202020202020207D20656C7365207B0D0A202020202020202020206966';
wwv_flow_api.g_varchar2_table(136) := '2028656C656D2E76616C7565203D3D3D20646174756D2E76616C7565292072657475726E20747275653B0D0A20202020202020207D0D0A2020202020207D0D0A20202020202072657475726E2066616C73653B0D0A202020207D3B0D0A20200D0A202020';
wwv_flow_api.g_varchar2_table(137) := '207661722064726F70646F776E5669657773203D207B7D3B0D0A202020202428646F63756D656E74292E6F6E2827636C69636B272C2066756E6374696F6E20286529207B0D0A202020202020766172206964203D20652E6F726967696E616C4576656E74';
wwv_flow_api.g_varchar2_table(138) := '20262620652E6F726967696E616C4576656E742E6B65657054657874436F6D706C65746544726F70646F776E3B0D0A202020202020242E656163682864726F70646F776E56696577732C2066756E6374696F6E20286B65792C207669657729207B0D0A20';
wwv_flow_api.g_varchar2_table(139) := '20202020202020696620286B657920213D3D20696429207B20766965772E6465616374697661746528293B207D0D0A2020202020207D293B0D0A202020207D293B0D0A20200D0A2020202076617220636F6D6D616E6473203D207B0D0A20202020202053';
wwv_flow_api.g_varchar2_table(140) := '4B49505F44454641554C543A20302C0D0A2020202020204B45595F55503A20312C0D0A2020202020204B45595F444F574E3A20322C0D0A2020202020204B45595F454E5445523A20332C0D0A2020202020204B45595F5041474555503A20342C0D0A2020';
wwv_flow_api.g_varchar2_table(141) := '202020204B45595F50414745444F574E3A20352C0D0A2020202020204B45595F4553434150453A20360D0A202020207D3B0D0A20200D0A202020202F2F2044726F70646F776E20766965770D0A202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D0D0A20';
wwv_flow_api.g_varchar2_table(142) := '200D0A202020202F2F20436F6E7374727563742044726F70646F776E206F626A6563742E0D0A202020202F2F0D0A202020202F2F20656C656D656E74202D205465787461726561206F7220636F6E74656E746564697461626C6520656C656D656E742E0D';
wwv_flow_api.g_varchar2_table(143) := '0A2020202066756E6374696F6E2044726F70646F776E28656C656D656E742C20636F6D706C657465722C206F7074696F6E29207B0D0A202020202020746869732E24656C202020202020203D2044726F70646F776E2E637265617465456C656D656E7428';
wwv_flow_api.g_varchar2_table(144) := '6F7074696F6E293B0D0A202020202020746869732E636F6D706C65746572203D20636F6D706C657465723B0D0A202020202020746869732E696420202020202020203D20636F6D706C657465722E6964202B202764726F70646F776E273B0D0A20202020';
wwv_flow_api.g_varchar2_table(145) := '2020746869732E5F6461746120202020203D205B5D3B202F2F207A697070656420646174612E0D0A202020202020746869732E24696E707574456C20203D202428656C656D656E74293B0D0A202020202020746869732E6F7074696F6E202020203D206F';
wwv_flow_api.g_varchar2_table(146) := '7074696F6E3B0D0A20200D0A2020202020202F2F204F7665727269646520736574506F736974696F6E206D6574686F642E0D0A202020202020696620286F7074696F6E2E6C697374506F736974696F6E29207B20746869732E736574506F736974696F6E';
wwv_flow_api.g_varchar2_table(147) := '203D206F7074696F6E2E6C697374506F736974696F6E3B207D0D0A202020202020696620286F7074696F6E2E68656967687429207B20746869732E24656C2E686569676874286F7074696F6E2E686569676874293B207D0D0A2020202020207661722073';
wwv_flow_api.g_varchar2_table(148) := '656C66203D20746869733B0D0A202020202020242E65616368285B276D6178436F756E74272C2027706C6163656D656E74272C2027666F6F746572272C2027686561646572272C20276E6F526573756C74734D657373616765272C2027636C6173734E61';
wwv_flow_api.g_varchar2_table(149) := '6D65275D2C2066756E6374696F6E20285F692C206E616D6529207B0D0A2020202020202020696620286F7074696F6E5B6E616D655D20213D206E756C6C29207B2073656C665B6E616D655D203D206F7074696F6E5B6E616D655D3B207D0D0A2020202020';
wwv_flow_api.g_varchar2_table(150) := '207D293B0D0A202020202020746869732E5F62696E644576656E747328656C656D656E74293B0D0A20202020202064726F70646F776E56696577735B746869732E69645D203D20746869733B0D0A202020207D0D0A20200D0A20202020242E657874656E';
wwv_flow_api.g_varchar2_table(151) := '642844726F70646F776E2C207B0D0A2020202020202F2F20436C617373206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A202020202020637265617465456C656D656E743A2066756E6374696F6E20286F70';
wwv_flow_api.g_varchar2_table(152) := '74696F6E29207B0D0A20202020202020207661722024706172656E74203D206F7074696F6E2E617070656E64546F3B0D0A202020202020202069662028212824706172656E7420696E7374616E63656F6620242929207B2024706172656E74203D202428';
wwv_flow_api.g_varchar2_table(153) := '24706172656E74293B207D0D0A20202020202020207661722024656C203D202428273C756C3E3C2F756C3E27290D0A202020202020202020202E616464436C617373286F7074696F6E2E64726F70646F776E436C6173734E616D65290D0A202020202020';
wwv_flow_api.g_varchar2_table(154) := '202020202E6174747228276964272C202774657874636F6D706C6574652D64726F70646F776E2D27202B206F7074696F6E2E5F6F6964290D0A202020202020202020202E637373287B0D0A202020202020202020202020646973706C61793A20276E6F6E';
wwv_flow_api.g_varchar2_table(155) := '65272C0D0A2020202020202020202020206C6566743A20302C0D0A202020202020202020202020706F736974696F6E3A20276162736F6C757465272C0D0A2020202020202020202020207A496E6465783A206F7074696F6E2E7A496E6465780D0A202020';
wwv_flow_api.g_varchar2_table(156) := '202020202020207D290D0A202020202020202020202E617070656E64546F2824706172656E74293B0D0A202020202020202072657475726E2024656C3B0D0A2020202020207D0D0A202020207D293B0D0A20200D0A20202020242E657874656E64284472';
wwv_flow_api.g_varchar2_table(157) := '6F70646F776E2E70726F746F747970652C207B0D0A2020202020202F2F205075626C69632070726F706572746965730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A20202020202024656C3A202020202020206E75';
wwv_flow_api.g_varchar2_table(158) := '6C6C2C20202F2F206A5175657279206F626A656374206F6620756C2E64726F70646F776E2D6D656E7520656C656D656E742E0D0A20202020202024696E707574456C3A20206E756C6C2C20202F2F206A5175657279206F626A656374206F662074617267';
wwv_flow_api.g_varchar2_table(159) := '65742074657874617265612E0D0A202020202020636F6D706C657465723A206E756C6C2C0D0A202020202020666F6F7465723A202020206E756C6C2C0D0A2020202020206865616465723A202020206E756C6C2C0D0A20202020202069643A2020202020';
wwv_flow_api.g_varchar2_table(160) := '2020206E756C6C2C0D0A2020202020206D6178436F756E743A20206E756C6C2C0D0A202020202020706C6163656D656E743A2027272C0D0A20202020202073686F776E3A202020202066616C73652C0D0A202020202020646174613A2020202020205B5D';
wwv_flow_api.g_varchar2_table(161) := '2C20202020202F2F2053686F776E207A697070656420646174612E0D0A202020202020636C6173734E616D653A2027272C0D0A20200D0A2020202020202F2F205075626C6963206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(162) := '2D2D2D0D0A20200D0A20202020202064657374726F793A2066756E6374696F6E202829207B0D0A20202020202020202F2F20446F6E27742072656D6F76652024656C2062656361757365206974206D617920626520736861726564206279207365766572';
wwv_flow_api.g_varchar2_table(163) := '616C2074657874636F6D706C657465732E0D0A2020202020202020746869732E6465616374697661746528293B0D0A20200D0A2020202020202020746869732E24656C2E6F666628272E27202B20746869732E6964293B0D0A2020202020202020746869';
wwv_flow_api.g_varchar2_table(164) := '732E24696E707574456C2E6F666628272E27202B20746869732E6964293B0D0A2020202020202020746869732E636C65617228293B0D0A2020202020202020746869732E24656C2E72656D6F766528293B0D0A2020202020202020746869732E24656C20';
wwv_flow_api.g_varchar2_table(165) := '3D20746869732E24696E707574456C203D20746869732E636F6D706C65746572203D206E756C6C3B0D0A202020202020202064656C6574652064726F70646F776E56696577735B746869732E69645D0D0A2020202020207D2C0D0A20200D0A2020202020';
wwv_flow_api.g_varchar2_table(166) := '2072656E6465723A2066756E6374696F6E20287A69707065644461746129207B0D0A202020202020202076617220636F6E74656E747348746D6C203D20746869732E5F6275696C64436F6E74656E7473287A697070656444617461293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(167) := '20202076617220756E7A697070656444617461203D20242E6D6170287A6970706564446174612C2066756E6374696F6E20286429207B2072657475726E20642E76616C75653B207D293B0D0A2020202020202020696620287A6970706564446174612E6C';
wwv_flow_api.g_varchar2_table(168) := '656E67746829207B0D0A20202020202020202020766172207374726174656779203D207A6970706564446174615B305D2E73747261746567793B0D0A202020202020202020206966202873747261746567792E696429207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(169) := '2020746869732E24656C2E617474722827646174612D7374726174656779272C2073747261746567792E6964293B0D0A202020202020202020207D20656C7365207B0D0A202020202020202020202020746869732E24656C2E72656D6F76654174747228';
wwv_flow_api.g_varchar2_table(170) := '27646174612D737472617465677927293B0D0A202020202020202020207D0D0A20202020202020202020746869732E5F72656E64657248656164657228756E7A697070656444617461293B0D0A20202020202020202020746869732E5F72656E64657246';
wwv_flow_api.g_varchar2_table(171) := '6F6F74657228756E7A697070656444617461293B0D0A2020202020202020202069662028636F6E74656E747348746D6C29207B0D0A202020202020202020202020746869732E5F72656E646572436F6E74656E747328636F6E74656E747348746D6C293B';
wwv_flow_api.g_varchar2_table(172) := '0D0A202020202020202020202020746869732E5F666974546F426F74746F6D28293B0D0A202020202020202020202020746869732E5F666974546F526967687428293B0D0A202020202020202020202020746869732E5F6163746976617465496E646578';
wwv_flow_api.g_varchar2_table(173) := '65644974656D28293B0D0A202020202020202020207D0D0A20202020202020202020746869732E5F7365745363726F6C6C28293B0D0A20202020202020207D20656C73652069662028746869732E6E6F526573756C74734D65737361676529207B0D0A20';
wwv_flow_api.g_varchar2_table(174) := '202020202020202020746869732E5F72656E6465724E6F526573756C74734D65737361676528756E7A697070656444617461293B0D0A20202020202020207D20656C73652069662028746869732E73686F776E29207B0D0A202020202020202020207468';
wwv_flow_api.g_varchar2_table(175) := '69732E6465616374697661746528293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A202020202020736574506F736974696F6E3A2066756E6374696F6E2028706F7329207B0D0A20202020202020202F2F204D616B652074686520';
wwv_flow_api.g_varchar2_table(176) := '64726F70646F776E2066697865642069662074686520696E70757420697320616C736F2066697865640D0A20202020202020202F2F20546869732063616E277420626520646F6E6520647572696E6720696E69742C2061732074657874636F6D706C6574';
wwv_flow_api.g_varchar2_table(177) := '65206D61792062652075736564206F6E206D756C7469706C6520656C656D656E7473206F6E207468652073616D6520706167650D0A20202020202020202F2F2042656361757365207468652073616D652064726F70646F776E2069732072657573656420';
wwv_flow_api.g_varchar2_table(178) := '626568696E6420746865207363656E65732C207765206E65656420746F207265636865636B2065766572792074696D65207468652064726F70646F776E2069732073686F7765640D0A202020202020202076617220706F736974696F6E203D2027616273';
wwv_flow_api.g_varchar2_table(179) := '6F6C757465273B0D0A20202020202020202F2F20436865636B20696620696E707574206F72206F6E65206F662069747320706172656E74732068617320706F736974696F6E696E67207765206E65656420746F20636172652061626F75740D0A20202020';
wwv_flow_api.g_varchar2_table(180) := '20202020746869732E24696E707574456C2E61646428746869732E24696E707574456C2E706172656E74732829292E656163682866756E6374696F6E2829207B0D0A20202020202020202020696628242874686973292E6373732827706F736974696F6E';
wwv_flow_api.g_varchar2_table(181) := '2729203D3D3D20276162736F6C7574652729202F2F2054686520656C656D656E7420686173206162736F6C75746520706F736974696F6E696E672C20736F206974277320616C6C204F4B0D0A20202020202020202020202072657475726E2066616C7365';
wwv_flow_api.g_varchar2_table(182) := '3B0D0A20202020202020202020696628242874686973292E6373732827706F736974696F6E2729203D3D3D202766697865642729207B0D0A202020202020202020202020706F732E746F70202D3D202477696E646F772E7363726F6C6C546F7028293B0D';
wwv_flow_api.g_varchar2_table(183) := '0A202020202020202020202020706F732E6C656674202D3D202477696E646F772E7363726F6C6C4C65667428293B0D0A202020202020202020202020706F736974696F6E203D20276669786564273B0D0A20202020202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(184) := '66616C73653B0D0A202020202020202020207D0D0A20202020202020207D293B0D0A2020202020202020746869732E24656C2E63737328746869732E5F6170706C79506C6163656D656E7428706F7329293B0D0A2020202020202020746869732E24656C';
wwv_flow_api.g_varchar2_table(185) := '2E637373287B20706F736974696F6E3A20706F736974696F6E207D293B202F2F2055706461746520706F736974696F6E696E670D0A20200D0A202020202020202072657475726E20746869733B0D0A2020202020207D2C0D0A20200D0A20202020202063';
wwv_flow_api.g_varchar2_table(186) := '6C6561723A2066756E6374696F6E202829207B0D0A2020202020202020746869732E24656C2E68746D6C282727293B0D0A2020202020202020746869732E64617461203D205B5D3B0D0A2020202020202020746869732E5F696E646578203D20303B0D0A';
wwv_flow_api.g_varchar2_table(187) := '2020202020202020746869732E5F24686561646572203D20746869732E5F24666F6F746572203D20746869732E5F246E6F526573756C74734D657373616765203D206E756C6C3B0D0A2020202020207D2C0D0A20200D0A20202020202061637469766174';
wwv_flow_api.g_varchar2_table(188) := '653A2066756E6374696F6E202829207B0D0A20202020202020206966202821746869732E73686F776E29207B0D0A20202020202020202020746869732E636C65617228293B0D0A20202020202020202020746869732E24656C2E73686F7728293B0D0A20';
wwv_flow_api.g_varchar2_table(189) := '20202020202020202069662028746869732E636C6173734E616D6529207B20746869732E24656C2E616464436C61737328746869732E636C6173734E616D65293B207D0D0A20202020202020202020746869732E636F6D706C657465722E666972652827';
wwv_flow_api.g_varchar2_table(190) := '74657874436F6D706C6574653A73686F7727293B0D0A20202020202020202020746869732E73686F776E203D20747275653B0D0A20202020202020207D0D0A202020202020202072657475726E20746869733B0D0A2020202020207D2C0D0A20200D0A20';
wwv_flow_api.g_varchar2_table(191) := '2020202020646561637469766174653A2066756E6374696F6E202829207B0D0A202020202020202069662028746869732E73686F776E29207B0D0A20202020202020202020746869732E24656C2E6869646528293B0D0A20202020202020202020696620';
wwv_flow_api.g_varchar2_table(192) := '28746869732E636C6173734E616D6529207B20746869732E24656C2E72656D6F7665436C61737328746869732E636C6173734E616D65293B207D0D0A20202020202020202020746869732E636F6D706C657465722E66697265282774657874436F6D706C';
wwv_flow_api.g_varchar2_table(193) := '6574653A6869646527293B0D0A20202020202020202020746869732E73686F776E203D2066616C73653B0D0A20202020202020207D0D0A202020202020202072657475726E20746869733B0D0A2020202020207D2C0D0A20200D0A202020202020697355';
wwv_flow_api.g_varchar2_table(194) := '703A2066756E6374696F6E20286529207B0D0A202020202020202072657475726E20652E6B6579436F6465203D3D3D203338207C7C2028652E6374726C4B657920262620652E6B6579436F6465203D3D3D203830293B20202F2F2055502C204374726C2D';
wwv_flow_api.g_varchar2_table(195) := '500D0A2020202020207D2C0D0A20200D0A2020202020206973446F776E3A2066756E6374696F6E20286529207B0D0A202020202020202072657475726E20652E6B6579436F6465203D3D3D203430207C7C2028652E6374726C4B657920262620652E6B65';
wwv_flow_api.g_varchar2_table(196) := '79436F6465203D3D3D203738293B20202F2F20444F574E2C204374726C2D4E0D0A2020202020207D2C0D0A20200D0A2020202020206973456E7465723A2066756E6374696F6E20286529207B0D0A2020202020202020766172206D6F6469666965727320';
wwv_flow_api.g_varchar2_table(197) := '3D20652E6374726C4B6579207C7C20652E616C744B6579207C7C20652E6D6574614B6579207C7C20652E73686966744B65793B0D0A202020202020202072657475726E20216D6F646966696572732026262028652E6B6579436F6465203D3D3D20313320';
wwv_flow_api.g_varchar2_table(198) := '7C7C20652E6B6579436F6465203D3D3D2039207C7C2028746869732E6F7074696F6E2E636F6D706C6574654F6E5370616365203D3D3D207472756520262620652E6B6579436F6465203D3D3D203332292920202F2F20454E5445522C205441420D0A2020';
wwv_flow_api.g_varchar2_table(199) := '202020207D2C0D0A20200D0A20202020202069735061676575703A2066756E6374696F6E20286529207B0D0A202020202020202072657475726E20652E6B6579436F6465203D3D3D2033333B20202F2F205041474555500D0A2020202020207D2C0D0A20';
wwv_flow_api.g_varchar2_table(200) := '200D0A202020202020697350616765646F776E3A2066756E6374696F6E20286529207B0D0A202020202020202072657475726E20652E6B6579436F6465203D3D3D2033343B20202F2F2050414745444F574E0D0A2020202020207D2C0D0A20200D0A2020';
wwv_flow_api.g_varchar2_table(201) := '2020202069734573636170653A2066756E6374696F6E20286529207B0D0A202020202020202072657475726E20652E6B6579436F6465203D3D3D2032373B20202F2F204553434150450D0A2020202020207D2C0D0A20200D0A2020202020202F2F205072';
wwv_flow_api.g_varchar2_table(202) := '69766174652070726F706572746965730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020205F646174613A202020206E756C6C2C20202F2F2043757272656E746C792073686F776E207A697070656420';
wwv_flow_api.g_varchar2_table(203) := '646174612E0D0A2020202020205F696E6465783A2020206E756C6C2C0D0A2020202020205F246865616465723A206E756C6C2C0D0A2020202020205F246E6F526573756C74734D6573736167653A206E756C6C2C0D0A2020202020205F24666F6F746572';
wwv_flow_api.g_varchar2_table(204) := '3A206E756C6C2C0D0A20200D0A2020202020202F2F2050726976617465206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020205F62696E644576656E74733A2066756E6374696F6E20282920';
wwv_flow_api.g_varchar2_table(205) := '7B0D0A2020202020202020746869732E24656C2E6F6E28276D6F757365646F776E2E27202B20746869732E69642C20272E74657874636F6D706C6574652D6974656D272C20242E70726F787928746869732E5F6F6E436C69636B2C207468697329293B0D';
wwv_flow_api.g_varchar2_table(206) := '0A2020202020202020746869732E24656C2E6F6E2827746F75636873746172742E27202B20746869732E69642C20272E74657874636F6D706C6574652D6974656D272C20242E70726F787928746869732E5F6F6E436C69636B2C207468697329293B0D0A';
wwv_flow_api.g_varchar2_table(207) := '2020202020202020746869732E24656C2E6F6E28276D6F7573656F7665722E27202B20746869732E69642C20272E74657874636F6D706C6574652D6974656D272C20242E70726F787928746869732E5F6F6E4D6F7573656F7665722C207468697329293B';
wwv_flow_api.g_varchar2_table(208) := '0D0A2020202020202020746869732E24696E707574456C2E6F6E28276B6579646F776E2E27202B20746869732E69642C20242E70726F787928746869732E5F6F6E4B6579646F776E2C207468697329293B0D0A2020202020207D2C0D0A20200D0A202020';
wwv_flow_api.g_varchar2_table(209) := '2020205F6F6E436C69636B3A2066756E6374696F6E20286529207B0D0A20202020202020207661722024656C203D202428652E746172676574293B0D0A2020202020202020652E70726576656E7444656661756C7428293B0D0A2020202020202020652E';
wwv_flow_api.g_varchar2_table(210) := '6F726967696E616C4576656E742E6B65657054657874436F6D706C65746544726F70646F776E203D20746869732E69643B0D0A2020202020202020696620282124656C2E686173436C617373282774657874636F6D706C6574652D6974656D272929207B';
wwv_flow_api.g_varchar2_table(211) := '0D0A2020202020202020202024656C203D2024656C2E636C6F7365737428272E74657874636F6D706C6574652D6974656D27293B0D0A20202020202020207D0D0A202020202020202076617220646174756D203D20746869732E646174615B7061727365';
wwv_flow_api.g_varchar2_table(212) := '496E742824656C2E646174612827696E64657827292C203130295D3B0D0A2020202020202020746869732E636F6D706C657465722E73656C65637428646174756D2E76616C75652C20646174756D2E73747261746567792C2065293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(213) := '20207661722073656C66203D20746869733B0D0A20202020202020202F2F204465616374697665206174206E657874207469636B20746F20616C6C6F77206F74686572206576656E742068616E646C65727320746F206B6E6F7720776865746865720D0A';
wwv_flow_api.g_varchar2_table(214) := '20202020202020202F2F207468652064726F70646F776E20686173206265656E2073686F776E206F72206E6F742E0D0A202020202020202073657454696D656F75742866756E6374696F6E202829207B0D0A2020202020202020202073656C662E646561';
wwv_flow_api.g_varchar2_table(215) := '6374697661746528293B0D0A2020202020202020202069662028652E74797065203D3D3D2027746F75636873746172742729207B0D0A20202020202020202020202073656C662E24696E707574456C2E666F63757328293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(216) := '7D0D0A20202020202020207D2C2030293B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F20416374697661746520686F7665726564206974656D2E0D0A2020202020205F6F6E4D6F7573656F7665723A2066756E6374696F6E20286529207B';
wwv_flow_api.g_varchar2_table(217) := '0D0A20202020202020207661722024656C203D202428652E746172676574293B0D0A2020202020202020652E70726576656E7444656661756C7428293B0D0A2020202020202020696620282124656C2E686173436C617373282774657874636F6D706C65';
wwv_flow_api.g_varchar2_table(218) := '74652D6974656D272929207B0D0A2020202020202020202024656C203D2024656C2E636C6F7365737428272E74657874636F6D706C6574652D6974656D27293B0D0A20202020202020207D0D0A2020202020202020746869732E5F696E646578203D2070';
wwv_flow_api.g_varchar2_table(219) := '61727365496E742824656C2E646174612827696E64657827292C203130293B0D0A2020202020202020746869732E5F6163746976617465496E64657865644974656D28293B0D0A2020202020207D2C0D0A20200D0A2020202020205F6F6E4B6579646F77';
wwv_flow_api.g_varchar2_table(220) := '6E3A2066756E6374696F6E20286529207B0D0A20202020202020206966202821746869732E73686F776E29207B2072657475726E3B207D0D0A20200D0A202020202020202076617220636F6D6D616E643B0D0A20200D0A20202020202020206966202824';
wwv_flow_api.g_varchar2_table(221) := '2E697346756E6374696F6E28746869732E6F7074696F6E2E6F6E4B6579646F776E2929207B0D0A20202020202020202020636F6D6D616E64203D20746869732E6F7074696F6E2E6F6E4B6579646F776E28652C20636F6D6D616E6473293B0D0A20202020';
wwv_flow_api.g_varchar2_table(222) := '202020207D0D0A20200D0A202020202020202069662028636F6D6D616E64203D3D206E756C6C29207B0D0A20202020202020202020636F6D6D616E64203D20746869732E5F64656661756C744B6579646F776E2865293B0D0A20202020202020207D0D0A';
wwv_flow_api.g_varchar2_table(223) := '20200D0A20202020202020207377697463682028636F6D6D616E6429207B0D0A202020202020202020206361736520636F6D6D616E64732E4B45595F55503A0D0A202020202020202020202020652E70726576656E7444656661756C7428293B0D0A2020';
wwv_flow_api.g_varchar2_table(224) := '20202020202020202020746869732E5F757028293B0D0A202020202020202020202020627265616B3B0D0A202020202020202020206361736520636F6D6D616E64732E4B45595F444F574E3A0D0A202020202020202020202020652E70726576656E7444';
wwv_flow_api.g_varchar2_table(225) := '656661756C7428293B0D0A202020202020202020202020746869732E5F646F776E28293B0D0A202020202020202020202020627265616B3B0D0A202020202020202020206361736520636F6D6D616E64732E4B45595F454E5445523A0D0A202020202020';
wwv_flow_api.g_varchar2_table(226) := '202020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020746869732E5F656E7465722865293B0D0A202020202020202020202020627265616B3B0D0A202020202020202020206361736520636F6D6D616E64732E';
wwv_flow_api.g_varchar2_table(227) := '4B45595F5041474555503A0D0A202020202020202020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020746869732E5F70616765757028293B0D0A202020202020202020202020627265616B3B0D0A2020202020';
wwv_flow_api.g_varchar2_table(228) := '20202020206361736520636F6D6D616E64732E4B45595F50414745444F574E3A0D0A202020202020202020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020746869732E5F70616765646F776E28293B0D0A2020';
wwv_flow_api.g_varchar2_table(229) := '20202020202020202020627265616B3B0D0A202020202020202020206361736520636F6D6D616E64732E4B45595F4553434150453A0D0A202020202020202020202020652E70726576656E7444656661756C7428293B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(230) := '746869732E6465616374697661746528293B0D0A202020202020202020202020627265616B3B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F64656661756C744B6579646F776E3A2066756E6374696F6E20286529';
wwv_flow_api.g_varchar2_table(231) := '207B0D0A202020202020202069662028746869732E6973557028652929207B0D0A2020202020202020202072657475726E20636F6D6D616E64732E4B45595F55503B0D0A20202020202020207D20656C73652069662028746869732E6973446F776E2865';
wwv_flow_api.g_varchar2_table(232) := '2929207B0D0A2020202020202020202072657475726E20636F6D6D616E64732E4B45595F444F574E3B0D0A20202020202020207D20656C73652069662028746869732E6973456E74657228652929207B0D0A2020202020202020202072657475726E2063';
wwv_flow_api.g_varchar2_table(233) := '6F6D6D616E64732E4B45595F454E5445523B0D0A20202020202020207D20656C73652069662028746869732E697350616765757028652929207B0D0A2020202020202020202072657475726E20636F6D6D616E64732E4B45595F5041474555503B0D0A20';
wwv_flow_api.g_varchar2_table(234) := '202020202020207D20656C73652069662028746869732E697350616765646F776E28652929207B0D0A2020202020202020202072657475726E20636F6D6D616E64732E4B45595F50414745444F574E3B0D0A20202020202020207D20656C736520696620';
wwv_flow_api.g_varchar2_table(235) := '28746869732E697345736361706528652929207B0D0A2020202020202020202072657475726E20636F6D6D616E64732E4B45595F4553434150453B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F75703A2066756E';
wwv_flow_api.g_varchar2_table(236) := '6374696F6E202829207B0D0A202020202020202069662028746869732E5F696E646578203D3D3D203029207B0D0A20202020202020202020746869732E5F696E646578203D20746869732E646174612E6C656E677468202D20313B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(237) := '207D20656C7365207B0D0A20202020202020202020746869732E5F696E646578202D3D20313B0D0A20202020202020207D0D0A2020202020202020746869732E5F6163746976617465496E64657865644974656D28293B0D0A2020202020202020746869';
wwv_flow_api.g_varchar2_table(238) := '732E5F7365745363726F6C6C28293B0D0A2020202020207D2C0D0A20200D0A2020202020205F646F776E3A2066756E6374696F6E202829207B0D0A202020202020202069662028746869732E5F696E646578203D3D3D20746869732E646174612E6C656E';
wwv_flow_api.g_varchar2_table(239) := '677468202D203129207B0D0A20202020202020202020746869732E5F696E646578203D20303B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020746869732E5F696E646578202B3D20313B0D0A20202020202020207D0D0A2020';
wwv_flow_api.g_varchar2_table(240) := '202020202020746869732E5F6163746976617465496E64657865644974656D28293B0D0A2020202020202020746869732E5F7365745363726F6C6C28293B0D0A2020202020207D2C0D0A20200D0A2020202020205F656E7465723A2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(241) := '20286529207B0D0A202020202020202076617220646174756D203D20746869732E646174615B7061727365496E7428746869732E5F676574416374697665456C656D656E7428292E646174612827696E64657827292C203130295D3B0D0A202020202020';
wwv_flow_api.g_varchar2_table(242) := '2020746869732E636F6D706C657465722E73656C65637428646174756D2E76616C75652C20646174756D2E73747261746567792C2065293B0D0A2020202020202020746869732E6465616374697661746528293B0D0A2020202020207D2C0D0A20200D0A';
wwv_flow_api.g_varchar2_table(243) := '2020202020205F7061676575703A2066756E6374696F6E202829207B0D0A202020202020202076617220746172676574203D20303B0D0A2020202020202020766172207468726573686F6C64203D20746869732E5F676574416374697665456C656D656E';
wwv_flow_api.g_varchar2_table(244) := '7428292E706F736974696F6E28292E746F70202D20746869732E24656C2E696E6E657248656967687428293B0D0A2020202020202020746869732E24656C2E6368696C6472656E28292E656163682866756E6374696F6E20286929207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(245) := '202020202069662028242874686973292E706F736974696F6E28292E746F70202B20242874686973292E6F757465724865696768742829203E207468726573686F6C6429207B0D0A202020202020202020202020746172676574203D20693B0D0A202020';
wwv_flow_api.g_varchar2_table(246) := '20202020202020202072657475726E2066616C73653B0D0A202020202020202020207D0D0A20202020202020207D293B0D0A2020202020202020746869732E5F696E646578203D207461726765743B0D0A2020202020202020746869732E5F6163746976';
wwv_flow_api.g_varchar2_table(247) := '617465496E64657865644974656D28293B0D0A2020202020202020746869732E5F7365745363726F6C6C28293B0D0A2020202020207D2C0D0A20200D0A2020202020205F70616765646F776E3A2066756E6374696F6E202829207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(248) := '2076617220746172676574203D20746869732E646174612E6C656E677468202D20313B0D0A2020202020202020766172207468726573686F6C64203D20746869732E5F676574416374697665456C656D656E7428292E706F736974696F6E28292E746F70';
wwv_flow_api.g_varchar2_table(249) := '202B20746869732E24656C2E696E6E657248656967687428293B0D0A2020202020202020746869732E24656C2E6368696C6472656E28292E656163682866756E6374696F6E20286929207B0D0A2020202020202020202069662028242874686973292E70';
wwv_flow_api.g_varchar2_table(250) := '6F736974696F6E28292E746F70203E207468726573686F6C6429207B0D0A202020202020202020202020746172676574203D20693B0D0A20202020202020202020202072657475726E2066616C73650D0A202020202020202020207D0D0A202020202020';
wwv_flow_api.g_varchar2_table(251) := '20207D293B0D0A2020202020202020746869732E5F696E646578203D207461726765743B0D0A2020202020202020746869732E5F6163746976617465496E64657865644974656D28293B0D0A2020202020202020746869732E5F7365745363726F6C6C28';
wwv_flow_api.g_varchar2_table(252) := '293B0D0A2020202020207D2C0D0A20200D0A2020202020205F6163746976617465496E64657865644974656D3A2066756E6374696F6E202829207B0D0A2020202020202020746869732E24656C2E66696E6428272E74657874636F6D706C6574652D6974';
wwv_flow_api.g_varchar2_table(253) := '656D2E61637469766527292E72656D6F7665436C617373282761637469766527293B0D0A2020202020202020746869732E5F676574416374697665456C656D656E7428292E616464436C617373282761637469766527293B0D0A2020202020207D2C0D0A';
wwv_flow_api.g_varchar2_table(254) := '20200D0A2020202020205F676574416374697665456C656D656E743A2066756E6374696F6E202829207B0D0A202020202020202072657475726E20746869732E24656C2E6368696C6472656E28272E74657874636F6D706C6574652D6974656D3A6E7468';
wwv_flow_api.g_varchar2_table(255) := '2827202B20746869732E5F696E646578202B20272927293B0D0A2020202020207D2C0D0A20200D0A2020202020205F7365745363726F6C6C3A2066756E6374696F6E202829207B0D0A20202020202020207661722024616374697665456C203D20746869';
wwv_flow_api.g_varchar2_table(256) := '732E5F676574416374697665456C656D656E7428293B0D0A2020202020202020766172206974656D546F70203D2024616374697665456C2E706F736974696F6E28292E746F703B0D0A2020202020202020766172206974656D486569676874203D202461';
wwv_flow_api.g_varchar2_table(257) := '6374697665456C2E6F7574657248656967687428293B0D0A20202020202020207661722076697369626C65486569676874203D20746869732E24656C2E696E6E657248656967687428293B0D0A20202020202020207661722076697369626C65546F7020';
wwv_flow_api.g_varchar2_table(258) := '3D20746869732E24656C2E7363726F6C6C546F7028293B0D0A202020202020202069662028746869732E5F696E646578203D3D3D2030207C7C20746869732E5F696E646578203D3D20746869732E646174612E6C656E677468202D2031207C7C20697465';
wwv_flow_api.g_varchar2_table(259) := '6D546F70203C203029207B0D0A20202020202020202020746869732E24656C2E7363726F6C6C546F70286974656D546F70202B2076697369626C65546F70293B0D0A20202020202020207D20656C736520696620286974656D546F70202B206974656D48';
wwv_flow_api.g_varchar2_table(260) := '6569676874203E2076697369626C6548656967687429207B0D0A20202020202020202020746869732E24656C2E7363726F6C6C546F70286974656D546F70202B206974656D486569676874202B2076697369626C65546F70202D2076697369626C654865';
wwv_flow_api.g_varchar2_table(261) := '69676874293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F6275696C64436F6E74656E74733A2066756E6374696F6E20287A69707065644461746129207B0D0A202020202020202076617220646174756D2C2069';
wwv_flow_api.g_varchar2_table(262) := '2C20696E6465783B0D0A20202020202020207661722068746D6C203D2027273B0D0A2020202020202020666F72202869203D20303B2069203C207A6970706564446174612E6C656E6774683B20692B2B29207B0D0A202020202020202020206966202874';
wwv_flow_api.g_varchar2_table(263) := '6869732E646174612E6C656E677468203D3D3D20746869732E6D6178436F756E742920627265616B3B0D0A20202020202020202020646174756D203D207A6970706564446174615B695D3B0D0A2020202020202020202069662028696E636C7564652874';
wwv_flow_api.g_varchar2_table(264) := '6869732E646174612C20646174756D2929207B20636F6E74696E75653B207D0D0A20202020202020202020696E646578203D20746869732E646174612E6C656E6774683B0D0A20202020202020202020746869732E646174612E7075736828646174756D';
wwv_flow_api.g_varchar2_table(265) := '293B0D0A2020202020202020202068746D6C202B3D20273C6C6920636C6173733D2274657874636F6D706C6574652D6974656D2220646174612D696E6465783D2227202B20696E646578202B2027223E3C613E273B0D0A2020202020202020202068746D';
wwv_flow_api.g_varchar2_table(266) := '6C202B3D202020646174756D2E73747261746567792E74656D706C61746528646174756D2E76616C75652C20646174756D2E7465726D293B0D0A2020202020202020202068746D6C202B3D20273C2F613E3C2F6C693E273B0D0A20202020202020207D0D';
wwv_flow_api.g_varchar2_table(267) := '0A202020202020202072657475726E2068746D6C3B0D0A2020202020207D2C0D0A20200D0A2020202020205F72656E6465724865616465723A2066756E6374696F6E2028756E7A69707065644461746129207B0D0A202020202020202069662028746869';
wwv_flow_api.g_varchar2_table(268) := '732E68656164657229207B0D0A202020202020202020206966202821746869732E5F2468656164657229207B0D0A202020202020202020202020746869732E5F24686561646572203D202428273C6C6920636C6173733D2274657874636F6D706C657465';
wwv_flow_api.g_varchar2_table(269) := '2D686561646572223E3C2F6C693E27292E70726570656E64546F28746869732E24656C293B0D0A202020202020202020207D0D0A202020202020202020207661722068746D6C203D20242E697346756E6374696F6E28746869732E68656164657229203F';
wwv_flow_api.g_varchar2_table(270) := '20746869732E68656164657228756E7A69707065644461746129203A20746869732E6865616465723B0D0A20202020202020202020746869732E5F246865616465722E68746D6C2868746D6C293B0D0A20202020202020207D0D0A2020202020207D2C0D';
wwv_flow_api.g_varchar2_table(271) := '0A20200D0A2020202020205F72656E646572466F6F7465723A2066756E6374696F6E2028756E7A69707065644461746129207B0D0A202020202020202069662028746869732E666F6F74657229207B0D0A20202020202020202020696620282174686973';
wwv_flow_api.g_varchar2_table(272) := '2E5F24666F6F74657229207B0D0A202020202020202020202020746869732E5F24666F6F746572203D202428273C6C6920636C6173733D2274657874636F6D706C6574652D666F6F746572223E3C2F6C693E27292E617070656E64546F28746869732E24';
wwv_flow_api.g_varchar2_table(273) := '656C293B0D0A202020202020202020207D0D0A202020202020202020207661722068746D6C203D20242E697346756E6374696F6E28746869732E666F6F74657229203F20746869732E666F6F74657228756E7A69707065644461746129203A2074686973';
wwv_flow_api.g_varchar2_table(274) := '2E666F6F7465723B0D0A20202020202020202020746869732E5F24666F6F7465722E68746D6C2868746D6C293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F72656E6465724E6F526573756C74734D6573736167';
wwv_flow_api.g_varchar2_table(275) := '653A2066756E6374696F6E2028756E7A69707065644461746129207B0D0A202020202020202069662028746869732E6E6F526573756C74734D65737361676529207B0D0A202020202020202020206966202821746869732E5F246E6F526573756C74734D';
wwv_flow_api.g_varchar2_table(276) := '65737361676529207B0D0A202020202020202020202020746869732E5F246E6F526573756C74734D657373616765203D202428273C6C6920636C6173733D2274657874636F6D706C6574652D6E6F2D726573756C74732D6D657373616765223E3C2F6C69';
wwv_flow_api.g_varchar2_table(277) := '3E27292E617070656E64546F28746869732E24656C293B0D0A202020202020202020207D0D0A202020202020202020207661722068746D6C203D20242E697346756E6374696F6E28746869732E6E6F526573756C74734D65737361676529203F20746869';
wwv_flow_api.g_varchar2_table(278) := '732E6E6F526573756C74734D65737361676528756E7A69707065644461746129203A20746869732E6E6F526573756C74734D6573736167653B0D0A20202020202020202020746869732E5F246E6F526573756C74734D6573736167652E68746D6C286874';
wwv_flow_api.g_varchar2_table(279) := '6D6C293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F72656E646572436F6E74656E74733A2066756E6374696F6E202868746D6C29207B0D0A202020202020202069662028746869732E5F24666F6F7465722920';
wwv_flow_api.g_varchar2_table(280) := '7B0D0A20202020202020202020746869732E5F24666F6F7465722E6265666F72652868746D6C293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020746869732E24656C2E617070656E642868746D6C293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(281) := '20207D0D0A2020202020207D2C0D0A20200D0A2020202020205F666974546F426F74746F6D3A2066756E6374696F6E2829207B0D0A20202020202020207661722077696E646F775363726F6C6C426F74746F6D203D202477696E646F772E7363726F6C6C';
wwv_flow_api.g_varchar2_table(282) := '546F702829202B202477696E646F772E68656967687428293B0D0A202020202020202076617220686569676874203D20746869732E24656C2E68656967687428293B0D0A20202020202020206966202828746869732E24656C2E706F736974696F6E2829';
wwv_flow_api.g_varchar2_table(283) := '2E746F70202B2068656967687429203E2077696E646F775363726F6C6C426F74746F6D29207B0D0A202020202020202020202F2F206F6E6C7920646F207468697320696620776520617265206E6F7420696E20616E20696672616D650D0A202020202020';
wwv_flow_api.g_varchar2_table(284) := '202020206966202821746869732E636F6D706C657465722E24696672616D6529207B0D0A202020202020202020202020746869732E24656C2E6F6666736574287B746F703A2077696E646F775363726F6C6C426F74746F6D202D206865696768747D293B';
wwv_flow_api.g_varchar2_table(285) := '0D0A202020202020202020207D0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F666974546F52696768743A2066756E6374696F6E2829207B0D0A20202020202020202F2F20576520646F6E2774206B6E6F7720686F';
wwv_flow_api.g_varchar2_table(286) := '772077696465206F757220636F6E74656E7420697320756E74696C207468652062726F7773657220706F736974696F6E732075732C20616E64206174207468617420706F696E7420697420636C6970732075730D0A20202020202020202F2F20746F2074';
wwv_flow_api.g_varchar2_table(287) := '686520646F63756D656E7420776964746820736F20776520646F6E2774206B6E6F7720696620776520776F756C642068617665206F76657272756E2069742E20417320612068657572697374696320746F2061766F6964207468617420636C697070696E';
wwv_flow_api.g_varchar2_table(288) := '670D0A20202020202020202F2F20287768696368206D616B6573206F757220656C656D656E74732077726170206F6E746F20746865206E657874206C696E6520616E6420636F727275707420746865206E657874206974656D292C206966207765277265';
wwv_flow_api.g_varchar2_table(289) := '20636C6F736520746F207468652072696768740D0A20202020202020202F2F20656467652C206D6F7665206C6566742E20576520646F6E2774206B6E6F7720686F772066617220746F206D6F7665206C6566742C20736F206A757374206B656570206E75';
wwv_flow_api.g_varchar2_table(290) := '6467696E672061206269742E0D0A202020202020202076617220746F6C6572616E6365203D20746869732E6F7074696F6E2E7269676874456467654F66667365743B202F2F20706978656C732E204D616B65207769646572207468616E20766572746963';
wwv_flow_api.g_varchar2_table(291) := '616C207363726F6C6C6261722062656361757365207765206D69676874206E6F742062652061626C6520746F2075736520746861742073706163652E0D0A2020202020202020766172206C6173744F6666736574203D20746869732E24656C2E6F666673';
wwv_flow_api.g_varchar2_table(292) := '657428292E6C6566742C206F66667365743B0D0A2020202020202020766172207769647468203D20746869732E24656C2E776964746828293B0D0A2020202020202020766172206D61784C656674203D202477696E646F772E77696474682829202D2074';
wwv_flow_api.g_varchar2_table(293) := '6F6C6572616E63653B0D0A20202020202020207768696C6520286C6173744F6666736574202B207769647468203E206D61784C65667429207B0D0A20202020202020202020746869732E24656C2E6F6666736574287B6C6566743A206C6173744F666673';
wwv_flow_api.g_varchar2_table(294) := '6574202D20746F6C6572616E63657D293B0D0A202020202020202020206F6666736574203D20746869732E24656C2E6F666673657428292E6C6566743B0D0A20202020202020202020696620286F6666736574203E3D206C6173744F666673657429207B';
wwv_flow_api.g_varchar2_table(295) := '20627265616B3B207D0D0A202020202020202020206C6173744F6666736574203D206F66667365743B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020205F6170706C79506C6163656D656E743A2066756E6374696F6E20';
wwv_flow_api.g_varchar2_table(296) := '28706F736974696F6E29207B0D0A20202020202020202F2F204966207468652027706C6163656D656E7427206F7074696F6E2073657420746F2027746F70272C206D6F76652074686520706F736974696F6E2061626F76652074686520656C656D656E74';
wwv_flow_api.g_varchar2_table(297) := '2E0D0A202020202020202069662028746869732E706C6163656D656E742E696E6465784F662827746F70272920213D3D202D3129207B0D0A202020202020202020202F2F204F76657277726974652074686520706F736974696F6E206F626A6563742074';
wwv_flow_api.g_varchar2_table(298) := '6F20736574207468652027626F74746F6D272070726F706572747920696E7374656164206F662074686520746F702E0D0A20202020202020202020706F736974696F6E203D207B0D0A202020202020202020202020746F703A20276175746F272C0D0A20';
wwv_flow_api.g_varchar2_table(299) := '2020202020202020202020626F74746F6D3A20746869732E24656C2E706172656E7428292E6865696768742829202D20706F736974696F6E2E746F70202B20706F736974696F6E2E6C696E654865696768742C0D0A2020202020202020202020206C6566';
wwv_flow_api.g_varchar2_table(300) := '743A20706F736974696F6E2E6C6566740D0A202020202020202020207D3B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020706F736974696F6E2E626F74746F6D203D20276175746F273B0D0A2020202020202020202064656C';
wwv_flow_api.g_varchar2_table(301) := '65746520706F736974696F6E2E6C696E654865696768743B0D0A20202020202020207D0D0A202020202020202069662028746869732E706C6163656D656E742E696E6465784F6628276162736C656674272920213D3D202D3129207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(302) := '20202020706F736974696F6E2E6C656674203D20303B0D0A20202020202020207D20656C73652069662028746869732E706C6163656D656E742E696E6465784F6628276162737269676874272920213D3D202D3129207B0D0A2020202020202020202070';
wwv_flow_api.g_varchar2_table(303) := '6F736974696F6E2E7269676874203D20303B0D0A20202020202020202020706F736974696F6E2E6C656674203D20276175746F273B0D0A20202020202020207D0D0A202020202020202072657475726E20706F736974696F6E3B0D0A2020202020207D0D';
wwv_flow_api.g_varchar2_table(304) := '0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E44726F70646F776E203D2044726F70646F776E3B0D0A20202020242E657874656E6428242E666E2E74657874636F6D706C6574652C20636F6D6D616E6473293B';
wwv_flow_api.g_varchar2_table(305) := '0D0A20207D286A5175657279293B0D0A20200D0A20202B66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A202020202F2F204D656D6F697A652061207365617263682066756E6374696F6E2E0D0A202020';
wwv_flow_api.g_varchar2_table(306) := '20766172206D656D6F697A65203D2066756E6374696F6E202866756E6329207B0D0A202020202020766172206D656D6F203D207B7D3B0D0A20202020202072657475726E2066756E6374696F6E20287465726D2C2063616C6C6261636B29207B0D0A2020';
wwv_flow_api.g_varchar2_table(307) := '202020202020696620286D656D6F5B7465726D5D29207B0D0A2020202020202020202063616C6C6261636B286D656D6F5B7465726D5D293B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202066756E632E63616C6C2874686973';
wwv_flow_api.g_varchar2_table(308) := '2C207465726D2C2066756E6374696F6E20286461746129207B0D0A2020202020202020202020206D656D6F5B7465726D5D203D20286D656D6F5B7465726D5D207C7C205B5D292E636F6E6361742864617461293B0D0A2020202020202020202020206361';
wwv_flow_api.g_varchar2_table(309) := '6C6C6261636B2E6170706C79286E756C6C2C20617267756D656E7473293B0D0A202020202020202020207D293B0D0A20202020202020207D0D0A2020202020207D3B0D0A202020207D3B0D0A20200D0A2020202066756E6374696F6E2053747261746567';
wwv_flow_api.g_varchar2_table(310) := '79286F7074696F6E7329207B0D0A202020202020242E657874656E6428746869732C206F7074696F6E73293B0D0A20202020202069662028746869732E636163686529207B20746869732E736561726368203D206D656D6F697A6528746869732E736561';
wwv_flow_api.g_varchar2_table(311) := '726368293B207D0D0A202020207D0D0A20200D0A2020202053747261746567792E7061727365203D2066756E6374696F6E20287374726174656769657341727261792C20706172616D7329207B0D0A20202020202072657475726E20242E6D6170287374';
wwv_flow_api.g_varchar2_table(312) := '726174656769657341727261792C2066756E6374696F6E2028737472617465677929207B0D0A20202020202020207661722073747261746567794F626A203D206E6577205374726174656779287374726174656779293B0D0A2020202020202020737472';
wwv_flow_api.g_varchar2_table(313) := '61746567794F626A2E656C203D20706172616D732E656C3B0D0A202020202020202073747261746567794F626A2E24656C203D20706172616D732E24656C3B0D0A202020202020202072657475726E2073747261746567794F626A3B0D0A202020202020';
wwv_flow_api.g_varchar2_table(314) := '7D293B0D0A202020207D3B0D0A20200D0A20202020242E657874656E642853747261746567792E70726F746F747970652C207B0D0A2020202020202F2F205075626C69632070726F706572746965730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(315) := '2D2D2D2D2D2D2D0D0A20200D0A2020202020202F2F2052657175697265640D0A2020202020206D617463683A2020202020206E756C6C2C0D0A2020202020207265706C6163653A202020206E756C6C2C0D0A2020202020207365617263683A2020202020';
wwv_flow_api.g_varchar2_table(316) := '6E756C6C2C0D0A20200D0A2020202020202F2F204F7074696F6E616C0D0A20202020202069643A2020202020202020206E756C6C2C0D0A20202020202063616368653A20202020202066616C73652C0D0A202020202020636F6E746578743A2020202066';
wwv_flow_api.g_varchar2_table(317) := '756E6374696F6E202829207B2072657475726E20747275653B207D2C0D0A202020202020696E6465783A202020202020322C0D0A20202020202074656D706C6174653A20202066756E6374696F6E20286F626A29207B2072657475726E206F626A3B207D';
wwv_flow_api.g_varchar2_table(318) := '2C0D0A202020202020696450726F70657274793A206E756C6C0D0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E5374726174656779203D2053747261746567793B0D0A20200D0A20207D286A5175657279293B';
wwv_flow_api.g_varchar2_table(319) := '0D0A20200D0A20202B66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A20202020766172206E6F77203D20446174652E6E6F77207C7C2066756E6374696F6E202829207B2072657475726E206E65772044';
wwv_flow_api.g_varchar2_table(320) := '61746528292E67657454696D6528293B207D3B0D0A20200D0A202020202F2F2052657475726E7320612066756E6374696F6E2C20746861742C206173206C6F6E6720617320697420636F6E74696E75657320746F20626520696E766F6B65642C2077696C';
wwv_flow_api.g_varchar2_table(321) := '6C206E6F740D0A202020202F2F206265207472696767657265642E205468652066756E6374696F6E2077696C6C2062652063616C6C65642061667465722069742073746F7073206265696E672063616C6C656420666F720D0A202020202F2F2060776169';
wwv_flow_api.g_varchar2_table(322) := '7460206D7365632E0D0A202020202F2F0D0A202020202F2F2054686973207574696C6974792066756E6374696F6E20776173206F726967696E616C6C7920696D706C656D656E74656420617420556E64657273636F72652E6A732E0D0A20202020766172';
wwv_flow_api.g_varchar2_table(323) := '206465626F756E6365203D2066756E6374696F6E202866756E632C207761697429207B0D0A2020202020207661722074696D656F75742C20617267732C20636F6E746578742C2074696D657374616D702C20726573756C743B0D0A202020202020766172';
wwv_flow_api.g_varchar2_table(324) := '206C61746572203D2066756E6374696F6E202829207B0D0A2020202020202020766172206C617374203D206E6F772829202D2074696D657374616D703B0D0A2020202020202020696620286C617374203C207761697429207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(325) := '2074696D656F7574203D2073657454696D656F7574286C617465722C2077616974202D206C617374293B0D0A20202020202020207D20656C7365207B0D0A2020202020202020202074696D656F7574203D206E756C6C3B0D0A2020202020202020202072';
wwv_flow_api.g_varchar2_table(326) := '6573756C74203D2066756E632E6170706C7928636F6E746578742C2061726773293B0D0A20202020202020202020636F6E74657874203D2061726773203D206E756C6C3B0D0A20202020202020207D0D0A2020202020207D3B0D0A20200D0A2020202020';
wwv_flow_api.g_varchar2_table(327) := '2072657475726E2066756E6374696F6E202829207B0D0A2020202020202020636F6E74657874203D20746869733B0D0A202020202020202061726773203D20617267756D656E74733B0D0A202020202020202074696D657374616D70203D206E6F772829';
wwv_flow_api.g_varchar2_table(328) := '3B0D0A2020202020202020696620282174696D656F757429207B0D0A2020202020202020202074696D656F7574203D2073657454696D656F7574286C617465722C2077616974293B0D0A20202020202020207D0D0A202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(329) := '726573756C743B0D0A2020202020207D3B0D0A202020207D3B0D0A20200D0A2020202066756E6374696F6E2041646170746572202829207B7D0D0A20200D0A20202020242E657874656E6428416461707465722E70726F746F747970652C207B0D0A2020';
wwv_flow_api.g_varchar2_table(330) := '202020202F2F205075626C69632070726F706572746965730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A20202020202069643A20202020202020206E756C6C2C202F2F204964656E746974792E0D0A2020202020';
wwv_flow_api.g_varchar2_table(331) := '20636F6D706C657465723A206E756C6C2C202F2F20436F6D706C65746572206F626A65637420776869636820637265617465732069742E0D0A202020202020656C3A20202020202020206E756C6C2C202F2F20546578746172656120656C656D656E742E';
wwv_flow_api.g_varchar2_table(332) := '0D0A20202020202024656C3A202020202020206E756C6C2C202F2F206A5175657279206F626A656374206F66207468652074657874617265612E0D0A2020202020206F7074696F6E3A202020206E756C6C2C0D0A20200D0A2020202020202F2F20507562';
wwv_flow_api.g_varchar2_table(333) := '6C6963206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A202020202020696E697469616C697A653A2066756E6374696F6E2028656C656D656E742C20636F6D706C657465722C206F7074696F6E29207B0D';
wwv_flow_api.g_varchar2_table(334) := '0A2020202020202020746869732E656C20202020202020203D20656C656D656E743B0D0A2020202020202020746869732E24656C202020202020203D202428656C656D656E74293B0D0A2020202020202020746869732E696420202020202020203D2063';
wwv_flow_api.g_varchar2_table(335) := '6F6D706C657465722E6964202B20746869732E636F6E7374727563746F722E6E616D653B0D0A2020202020202020746869732E636F6D706C65746572203D20636F6D706C657465723B0D0A2020202020202020746869732E6F7074696F6E202020203D20';
wwv_flow_api.g_varchar2_table(336) := '6F7074696F6E3B0D0A20200D0A202020202020202069662028746869732E6F7074696F6E2E6465626F756E636529207B0D0A20202020202020202020746869732E5F6F6E4B65797570203D206465626F756E636528746869732E5F6F6E4B657975702C20';
wwv_flow_api.g_varchar2_table(337) := '746869732E6F7074696F6E2E6465626F756E6365293B0D0A20202020202020207D0D0A20200D0A2020202020202020746869732E5F62696E644576656E747328293B0D0A2020202020207D2C0D0A20200D0A20202020202064657374726F793A2066756E';
wwv_flow_api.g_varchar2_table(338) := '6374696F6E202829207B0D0A2020202020202020746869732E24656C2E6F666628272E27202B20746869732E6964293B202F2F2052656D6F766520616C6C206576656E742068616E646C6572732E0D0A2020202020202020746869732E24656C203D2074';
wwv_flow_api.g_varchar2_table(339) := '6869732E656C203D20746869732E636F6D706C65746572203D206E756C6C3B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F205570646174652074686520656C656D656E7420776974682074686520676976656E2076616C756520616E6420';
wwv_flow_api.g_varchar2_table(340) := '73747261746567792E0D0A2020202020202F2F0D0A2020202020202F2F2076616C7565202020202D205468652073656C6563746564206F626A6563742E204974206973206F6E65206F6620746865206974656D206F66207468652061727261790D0A2020';
wwv_flow_api.g_varchar2_table(341) := '202020202F2F2020202020202020202020207768696368207761732063616C6C6261636B65642066726F6D20746865207365617263682066756E6374696F6E2E0D0A2020202020202F2F207374726174656779202D205468652053747261746567792061';
wwv_flow_api.g_varchar2_table(342) := '73736F6369617465642077697468207468652073656C65637465642076616C75652E0D0A20202020202073656C6563743A2066756E6374696F6E20282F2A2076616C75652C207374726174656779202A2F29207B0D0A20202020202020207468726F7720';
wwv_flow_api.g_varchar2_table(343) := '6E6577204572726F7228274E6F7420696D706C656D656E74656427293B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F2052657475726E732074686520636172657427732072656C617469766520636F6F7264696E617465732066726F6D20';
wwv_flow_api.g_varchar2_table(344) := '626F64792773206C65667420746F7020636F726E65722E0D0A2020202020206765744361726574506F736974696F6E3A2066756E6374696F6E202829207B0D0A202020202020202076617220706F736974696F6E203D20746869732E5F67657443617265';
wwv_flow_api.g_varchar2_table(345) := '7452656C6174697665506F736974696F6E28293B0D0A2020202020202020766172206F6666736574203D20746869732E24656C2E6F666673657428293B0D0A20200D0A20202020202020202F2F2043616C63756C61746520746865206C65667420746F70';
wwv_flow_api.g_varchar2_table(346) := '20636F726E6572206F662060746869732E6F7074696F6E2E617070656E64546F6020656C656D656E742E0D0A20202020202020207661722024706172656E74203D20746869732E6F7074696F6E2E617070656E64546F3B0D0A2020202020202020696620';
wwv_flow_api.g_varchar2_table(347) := '2824706172656E7429207B0D0A202020202020202020202069662028212824706172656E7420696E7374616E63656F6620242929207B2024706172656E74203D20242824706172656E74293B207D0D0A202020202020202020202076617220706172656E';
wwv_flow_api.g_varchar2_table(348) := '744F6666736574203D2024706172656E742E6F6666736574506172656E7428292E6F666673657428293B0D0A20202020202020202020206F66667365742E746F70202D3D20706172656E744F66667365742E746F703B0D0A20202020202020202020206F';
wwv_flow_api.g_varchar2_table(349) := '66667365742E6C656674202D3D20706172656E744F66667365742E6C6566743B0D0A20202020202020207D0D0A20200D0A2020202020202020706F736974696F6E2E746F70202B3D206F66667365742E746F703B0D0A2020202020202020706F73697469';
wwv_flow_api.g_varchar2_table(350) := '6F6E2E6C656674202B3D206F66667365742E6C6566743B0D0A202020202020202072657475726E20706F736974696F6E3B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F20466F637573206F6E2074686520656C656D656E742E0D0A202020';
wwv_flow_api.g_varchar2_table(351) := '202020666F6375733A2066756E6374696F6E202829207B0D0A2020202020202020746869732E24656C2E666F63757328293B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F2050726976617465206D6574686F64730D0A2020202020202F2F';
wwv_flow_api.g_varchar2_table(352) := '202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020205F62696E644576656E74733A2066756E6374696F6E202829207B0D0A2020202020202020746869732E24656C2E6F6E28276B657975702E27202B20746869732E69642C20242E7072';
wwv_flow_api.g_varchar2_table(353) := '6F787928746869732E5F6F6E4B657975702C207468697329293B0D0A2020202020207D2C0D0A20200D0A2020202020205F6F6E4B657975703A2066756E6374696F6E20286529207B0D0A202020202020202069662028746869732E5F736B697053656172';
wwv_flow_api.g_varchar2_table(354) := '636828652929207B2072657475726E3B207D0D0A2020202020202020746869732E636F6D706C657465722E7472696767657228746869732E6765745465787446726F6D48656164546F436172657428292C2074727565293B0D0A2020202020207D2C0D0A';
wwv_flow_api.g_varchar2_table(355) := '20200D0A2020202020202F2F20537570707265737320736561726368696E672069662069742072657475726E7320747275652E0D0A2020202020205F736B69705365617263683A2066756E6374696F6E2028636C69636B4576656E7429207B0D0A202020';
wwv_flow_api.g_varchar2_table(356) := '20202020207377697463682028636C69636B4576656E742E6B6579436F646529207B0D0A202020202020202020206361736520393A20202F2F205441420D0A20202020202020202020636173652031333A202F2F20454E5445520D0A2020202020202020';
wwv_flow_api.g_varchar2_table(357) := '2020636173652031363A202F2F2053484946540D0A20202020202020202020636173652031373A202F2F204354524C0D0A20202020202020202020636173652031383A202F2F20414C540D0A20202020202020202020636173652033333A202F2F205041';
wwv_flow_api.g_varchar2_table(358) := '474555500D0A20202020202020202020636173652033343A202F2F2050414745444F574E0D0A20202020202020202020636173652034303A202F2F20444F574E0D0A20202020202020202020636173652033383A202F2F2055500D0A2020202020202020';
wwv_flow_api.g_varchar2_table(359) := '2020636173652032373A202F2F204553430D0A20202020202020202020202072657475726E20747275653B0D0A20202020202020207D0D0A202020202020202069662028636C69636B4576656E742E6374726C4B657929207377697463682028636C6963';
wwv_flow_api.g_varchar2_table(360) := '6B4576656E742E6B6579436F646529207B0D0A20202020202020202020636173652037383A202F2F204374726C2D4E0D0A20202020202020202020636173652038303A202F2F204374726C2D500D0A20202020202020202020202072657475726E207472';
wwv_flow_api.g_varchar2_table(361) := '75653B0D0A20202020202020207D0D0A2020202020207D0D0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E41646170746572203D20416461707465723B0D0A20207D286A5175657279293B0D0A20200D0A2020';
wwv_flow_api.g_varchar2_table(362) := '2B66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A202020202F2F20546578746172656120616461707465720D0A202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202F2F0D0A2020';
wwv_flow_api.g_varchar2_table(363) := '20202F2F204D616E6167696E6720612074657874617265612E20497420646F65736E2774206B6E6F7720612044726F70646F776E2E0D0A2020202066756E6374696F6E20546578746172656128656C656D656E742C20636F6D706C657465722C206F7074';
wwv_flow_api.g_varchar2_table(364) := '696F6E29207B0D0A202020202020746869732E696E697469616C697A6528656C656D656E742C20636F6D706C657465722C206F7074696F6E293B0D0A202020207D0D0A20200D0A20202020242E657874656E642854657874617265612E70726F746F7479';
wwv_flow_api.g_varchar2_table(365) := '70652C20242E666E2E74657874636F6D706C6574652E416461707465722E70726F746F747970652C207B0D0A2020202020202F2F205075626C6963206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020';
wwv_flow_api.g_varchar2_table(366) := '202020202F2F205570646174652074686520746578746172656120776974682074686520676976656E2076616C756520616E642073747261746567792E0D0A20202020202073656C6563743A2066756E6374696F6E202876616C75652C20737472617465';
wwv_flow_api.g_varchar2_table(367) := '67792C206529207B0D0A202020202020202076617220707265203D20746869732E6765745465787446726F6D48656164546F436172657428293B0D0A202020202020202076617220706F7374203D20746869732E656C2E76616C75652E73756273747269';
wwv_flow_api.g_varchar2_table(368) := '6E6728746869732E656C2E73656C656374696F6E456E64293B0D0A2020202020202020766172206E6577537562737472203D2073747261746567792E7265706C6163652876616C75652C2065293B0D0A2020202020202020766172207265674578703B0D';
wwv_flow_api.g_varchar2_table(369) := '0A202020202020202069662028747970656F66206E657753756273747220213D3D2027756E646566696E65642729207B0D0A2020202020202020202069662028242E69734172726179286E65775375627374722929207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(370) := '20706F7374203D206E65775375627374725B315D202B20706F73743B0D0A2020202020202020202020206E6577537562737472203D206E65775375627374725B305D3B0D0A202020202020202020207D0D0A20202020202020202020726567457870203D';
wwv_flow_api.g_varchar2_table(371) := '20242E697346756E6374696F6E2873747261746567792E6D6174636829203F2073747261746567792E6D617463682870726529203A2073747261746567792E6D617463683B0D0A20202020202020202020707265203D207072652E7265706C6163652872';
wwv_flow_api.g_varchar2_table(372) := '65674578702C206E6577537562737472293B0D0A20202020202020202020746869732E24656C2E76616C28707265202B20706F7374293B0D0A20202020202020202020746869732E656C2E73656C656374696F6E5374617274203D20746869732E656C2E';
wwv_flow_api.g_varchar2_table(373) := '73656C656374696F6E456E64203D207072652E6C656E6774683B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020206765745465787446726F6D48656164546F43617265743A2066756E6374696F6E202829207B0D0A2020';
wwv_flow_api.g_varchar2_table(374) := '20202020202072657475726E20746869732E656C2E76616C75652E737562737472696E6728302C20746869732E656C2E73656C656374696F6E456E64293B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F2050726976617465206D6574686F';
wwv_flow_api.g_varchar2_table(375) := '64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020205F676574436172657452656C6174697665506F736974696F6E3A2066756E6374696F6E202829207B0D0A20202020202020207661722070203D20242E';
wwv_flow_api.g_varchar2_table(376) := '666E2E74657874636F6D706C6574652E6765744361726574436F6F7264696E6174657328746869732E656C2C20746869732E656C2E73656C656374696F6E5374617274293B0D0A202020202020202072657475726E207B0D0A2020202020202020202074';
wwv_flow_api.g_varchar2_table(377) := '6F703A20702E746F70202B20746869732E5F63616C63756C6174654C696E654865696768742829202D20746869732E24656C2E7363726F6C6C546F7028292C0D0A202020202020202020206C6566743A20702E6C656674202D20746869732E24656C2E73';
wwv_flow_api.g_varchar2_table(378) := '63726F6C6C4C65667428292C0D0A202020202020202020206C696E654865696768743A20746869732E5F63616C63756C6174654C696E6548656967687428290D0A20202020202020207D3B0D0A2020202020207D2C0D0A20200D0A2020202020205F6361';
wwv_flow_api.g_varchar2_table(379) := '6C63756C6174654C696E654865696768743A2066756E6374696F6E202829207B0D0A2020202020202020766172206C696E65486569676874203D207061727365496E7428746869732E24656C2E63737328276C696E652D68656967687427292C20313029';
wwv_flow_api.g_varchar2_table(380) := '3B0D0A20202020202020206966202869734E614E286C696E654865696768742929207B0D0A202020202020202020202F2F20687474703A2F2F737461636B6F766572666C6F772E636F6D2F612F343531353437302F313239373333360D0A202020202020';
wwv_flow_api.g_varchar2_table(381) := '2020202076617220706172656E744E6F6465203D20746869732E656C2E706172656E744E6F64653B0D0A202020202020202020207661722074656D70203D20646F63756D656E742E637265617465456C656D656E7428746869732E656C2E6E6F64654E61';
wwv_flow_api.g_varchar2_table(382) := '6D65293B0D0A20202020202020202020766172207374796C65203D20746869732E656C2E7374796C653B0D0A2020202020202020202074656D702E736574417474726962757465280D0A202020202020202020202020277374796C65272C0D0A20202020';
wwv_flow_api.g_varchar2_table(383) := '2020202020202020276D617267696E3A3070783B70616464696E673A3070783B666F6E742D66616D696C793A27202B207374796C652E666F6E7446616D696C79202B20273B666F6E742D73697A653A27202B207374796C652E666F6E7453697A650D0A20';
wwv_flow_api.g_varchar2_table(384) := '202020202020202020293B0D0A2020202020202020202074656D702E696E6E657248544D4C203D202774657374273B0D0A20202020202020202020706172656E744E6F64652E617070656E644368696C642874656D70293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(385) := '6C696E65486569676874203D2074656D702E636C69656E744865696768743B0D0A20202020202020202020706172656E744E6F64652E72656D6F76654368696C642874656D70293B0D0A20202020202020207D0D0A202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(386) := '6C696E654865696768743B0D0A2020202020207D0D0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E5465787461726561203D2054657874617265613B0D0A20207D286A5175657279293B0D0A20200D0A20202B';
wwv_flow_api.g_varchar2_table(387) := '66756E6374696F6E20282429207B0D0A202020202775736520737472696374273B0D0A20200D0A202020207661722073656E74696E656C43686172203D2027E590B6273B0D0A20200D0A2020202066756E6374696F6E204945546578746172656128656C';
wwv_flow_api.g_varchar2_table(388) := '656D656E742C20636F6D706C657465722C206F7074696F6E29207B0D0A202020202020746869732E696E697469616C697A6528656C656D656E742C20636F6D706C657465722C206F7074696F6E293B0D0A2020202020202428273C7370616E3E27202B20';
wwv_flow_api.g_varchar2_table(389) := '73656E74696E656C43686172202B20273C2F7370616E3E27292E637373287B0D0A2020202020202020706F736974696F6E3A20276162736F6C757465272C0D0A2020202020202020746F703A202D393939392C0D0A20202020202020206C6566743A202D';
wwv_flow_api.g_varchar2_table(390) := '393939390D0A2020202020207D292E696E736572744265666F726528656C656D656E74293B0D0A202020207D0D0A20200D0A20202020242E657874656E6428494554657874617265612E70726F746F747970652C20242E666E2E74657874636F6D706C65';
wwv_flow_api.g_varchar2_table(391) := '74652E54657874617265612E70726F746F747970652C207B0D0A2020202020202F2F205075626C6963206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A20202020202073656C6563743A2066756E637469';
wwv_flow_api.g_varchar2_table(392) := '6F6E202876616C75652C2073747261746567792C206529207B0D0A202020202020202076617220707265203D20746869732E6765745465787446726F6D48656164546F436172657428293B0D0A202020202020202076617220706F7374203D2074686973';
wwv_flow_api.g_varchar2_table(393) := '2E656C2E76616C75652E737562737472696E67287072652E6C656E677468293B0D0A2020202020202020766172206E6577537562737472203D2073747261746567792E7265706C6163652876616C75652C2065293B0D0A20202020202020207661722072';
wwv_flow_api.g_varchar2_table(394) := '65674578703B0D0A202020202020202069662028747970656F66206E657753756273747220213D3D2027756E646566696E65642729207B0D0A2020202020202020202069662028242E69734172726179286E65775375627374722929207B0D0A20202020';
wwv_flow_api.g_varchar2_table(395) := '2020202020202020706F7374203D206E65775375627374725B315D202B20706F73743B0D0A2020202020202020202020206E6577537562737472203D206E65775375627374725B305D3B0D0A202020202020202020207D0D0A2020202020202020202072';
wwv_flow_api.g_varchar2_table(396) := '6567457870203D20242E697346756E6374696F6E2873747261746567792E6D6174636829203F2073747261746567792E6D617463682870726529203A2073747261746567792E6D617463683B0D0A20202020202020202020707265203D207072652E7265';
wwv_flow_api.g_varchar2_table(397) := '706C616365287265674578702C206E6577537562737472293B0D0A20202020202020202020746869732E24656C2E76616C28707265202B20706F7374293B0D0A20202020202020202020746869732E656C2E666F63757328293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(398) := '20207661722072616E6765203D20746869732E656C2E6372656174655465787452616E676528293B0D0A2020202020202020202072616E67652E636F6C6C617073652874727565293B0D0A2020202020202020202072616E67652E6D6F7665456E642827';
wwv_flow_api.g_varchar2_table(399) := '636861726163746572272C207072652E6C656E677468293B0D0A2020202020202020202072616E67652E6D6F766553746172742827636861726163746572272C207072652E6C656E677468293B0D0A2020202020202020202072616E67652E73656C6563';
wwv_flow_api.g_varchar2_table(400) := '7428293B0D0A20202020202020207D0D0A2020202020207D2C0D0A20200D0A2020202020206765745465787446726F6D48656164546F43617265743A2066756E6374696F6E202829207B0D0A2020202020202020746869732E656C2E666F63757328293B';
wwv_flow_api.g_varchar2_table(401) := '0D0A20202020202020207661722072616E6765203D20646F63756D656E742E73656C656374696F6E2E63726561746552616E676528293B0D0A202020202020202072616E67652E6D6F766553746172742827636861726163746572272C202D746869732E';
wwv_flow_api.g_varchar2_table(402) := '656C2E76616C75652E6C656E677468293B0D0A202020202020202076617220617272203D2072616E67652E746578742E73706C69742873656E74696E656C43686172290D0A202020202020202072657475726E206172722E6C656E677468203D3D3D2031';
wwv_flow_api.g_varchar2_table(403) := '203F206172725B305D203A206172725B315D3B0D0A2020202020207D0D0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E49455465787461726561203D20494554657874617265613B0D0A20207D286A51756572';
wwv_flow_api.g_varchar2_table(404) := '79293B0D0A20200D0A20202F2F204E4F54453A2054657874436F6D706C65746520706C7567696E2068617320636F6E74656E746564697461626C6520737570706F72742062757420697420646F6573206E6F7420776F726B0D0A20202F2F202020202020';
wwv_flow_api.g_varchar2_table(405) := '2066696E6520657370656369616C6C79206F6E206F6C64204945732E0D0A20202F2F20202020202020416E792070756C6C20726571756573747320617265205245414C4C592077656C636F6D652E0D0A20200D0A20202B66756E6374696F6E2028242920';
wwv_flow_api.g_varchar2_table(406) := '7B0D0A202020202775736520737472696374273B0D0A20200D0A202020202F2F20436F6E74656E744564697461626C6520616461707465720D0A202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202F2F0D0A2020';
wwv_flow_api.g_varchar2_table(407) := '20202F2F204164617074657220666F7220636F6E74656E746564697461626C6520656C656D656E74732E0D0A2020202066756E6374696F6E20436F6E74656E744564697461626C652028656C656D656E742C20636F6D706C657465722C206F7074696F6E';
wwv_flow_api.g_varchar2_table(408) := '29207B0D0A202020202020746869732E696E697469616C697A6528656C656D656E742C20636F6D706C657465722C206F7074696F6E293B0D0A202020207D0D0A20200D0A20202020242E657874656E6428436F6E74656E744564697461626C652E70726F';
wwv_flow_api.g_varchar2_table(409) := '746F747970652C20242E666E2E74657874636F6D706C6574652E416461707465722E70726F746F747970652C207B0D0A2020202020202F2F205075626C6963206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A2020';
wwv_flow_api.g_varchar2_table(410) := '0D0A2020202020202F2F205570646174652074686520636F6E74656E7420776974682074686520676976656E2076616C756520616E642073747261746567792E0D0A2020202020202F2F205768656E20616E2064726F70646F776E206974656D20697320';
wwv_flow_api.g_varchar2_table(411) := '73656C65637465642C2069742069732065786563757465642E0D0A20202020202073656C6563743A2066756E6374696F6E202876616C75652C2073747261746567792C206529207B0D0A202020202020202076617220707265203D20746869732E676574';
wwv_flow_api.g_varchar2_table(412) := '5465787446726F6D48656164546F436172657428293B0D0A20202020202020202F2F20757365206F776E6572446F63756D656E7420696E7374656164206F662077696E646F7720746F20737570706F727420696672616D65730D0A202020202020202076';
wwv_flow_api.g_varchar2_table(413) := '61722073656C203D20746869732E656C2E6F776E6572446F63756D656E742E67657453656C656374696F6E28293B0D0A20202020202020200D0A20202020202020207661722072616E6765203D2073656C2E67657452616E676541742830293B0D0A2020';
wwv_flow_api.g_varchar2_table(414) := '2020202020207661722073656C656374696F6E203D2072616E67652E636C6F6E6552616E676528293B0D0A202020202020202073656C656374696F6E2E73656C6563744E6F6465436F6E74656E74732872616E67652E7374617274436F6E7461696E6572';
wwv_flow_api.g_varchar2_table(415) := '293B0D0A202020202020202076617220636F6E74656E74203D2073656C656374696F6E2E746F537472696E6728293B0D0A202020202020202076617220706F7374203D20636F6E74656E742E737562737472696E672872616E67652E73746172744F6666';
wwv_flow_api.g_varchar2_table(416) := '736574293B0D0A2020202020202020766172206E6577537562737472203D2073747261746567792E7265706C6163652876616C75652C2065293B0D0A2020202020202020766172207265674578703B0D0A202020202020202069662028747970656F6620';
wwv_flow_api.g_varchar2_table(417) := '6E657753756273747220213D3D2027756E646566696E65642729207B0D0A2020202020202020202069662028242E69734172726179286E65775375627374722929207B0D0A202020202020202020202020706F7374203D206E65775375627374725B315D';
wwv_flow_api.g_varchar2_table(418) := '202B20706F73743B0D0A2020202020202020202020206E6577537562737472203D206E65775375627374725B305D3B0D0A202020202020202020207D0D0A20202020202020202020726567457870203D20242E697346756E6374696F6E28737472617465';
wwv_flow_api.g_varchar2_table(419) := '67792E6D6174636829203F2073747261746567792E6D617463682870726529203A2073747261746567792E6D617463683B0D0A20202020202020202020707265203D207072652E7265706C616365287265674578702C206E6577537562737472290D0A20';
wwv_flow_api.g_varchar2_table(420) := '202020202020202020202020202E7265706C616365282F20242F2C2022266E62737022293B202F2F20266E627370206E6563657373617279206174206C6561737420666F7220434B656469746F7220746F206E6F7420656174207370616365730D0A2020';
wwv_flow_api.g_varchar2_table(421) := '202020202020202072616E67652E73656C6563744E6F6465436F6E74656E74732872616E67652E7374617274436F6E7461696E6572293B0D0A2020202020202020202072616E67652E64656C657465436F6E74656E747328293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(422) := '20200D0A202020202020202020202F2F206372656174652074656D706F7261727920656C656D656E74730D0A202020202020202020207661722070726557726170706572203D20746869732E656C2E6F776E6572446F63756D656E742E63726561746545';
wwv_flow_api.g_varchar2_table(423) := '6C656D656E74282264697622293B0D0A20202020202020202020707265577261707065722E696E6E657248544D4C203D207072653B0D0A2020202020202020202076617220706F737457726170706572203D20746869732E656C2E6F776E6572446F6375';
wwv_flow_api.g_varchar2_table(424) := '6D656E742E637265617465456C656D656E74282264697622293B0D0A20202020202020202020706F7374577261707065722E696E6E657248544D4C203D20706F73743B0D0A202020202020202020200D0A202020202020202020202F2F20637265617465';
wwv_flow_api.g_varchar2_table(425) := '2074686520667261676D656E7420746861747320696E7365727465640D0A2020202020202020202076617220667261676D656E74203D20746869732E656C2E6F776E6572446F63756D656E742E637265617465446F63756D656E74467261676D656E7428';
wwv_flow_api.g_varchar2_table(426) := '293B0D0A20202020202020202020766172206368696C644E6F64653B0D0A20202020202020202020766172206C6173744F665072653B0D0A202020202020202020207768696C6520286368696C644E6F6465203D20707265577261707065722E66697273';
wwv_flow_api.g_varchar2_table(427) := '744368696C6429207B0D0A20202020202020202020202020206C6173744F66507265203D20667261676D656E742E617070656E644368696C64286368696C644E6F6465293B0D0A202020202020202020207D0D0A202020202020202020207768696C6520';
wwv_flow_api.g_varchar2_table(428) := '286368696C644E6F6465203D20706F7374577261707065722E66697273744368696C6429207B0D0A2020202020202020202020202020667261676D656E742E617070656E644368696C64286368696C644E6F6465293B0D0A202020202020202020207D0D';
wwv_flow_api.g_varchar2_table(429) := '0A202020202020202020200D0A202020202020202020202F2F20696E736572742074686520667261676D656E742026206A756D7020626568696E6420746865206C617374206E6F646520696E2022707265220D0A2020202020202020202072616E67652E';
wwv_flow_api.g_varchar2_table(430) := '696E736572744E6F646528667261676D656E74293B0D0A2020202020202020202072616E67652E73657453746172744166746572286C6173744F66507265293B0D0A202020202020202020200D0A2020202020202020202072616E67652E636F6C6C6170';
wwv_flow_api.g_varchar2_table(431) := '73652874727565293B0D0A2020202020202020202073656C2E72656D6F7665416C6C52616E67657328293B0D0A2020202020202020202073656C2E61646452616E67652872616E6765293B0D0A20202020202020207D0D0A2020202020207D2C0D0A2020';
wwv_flow_api.g_varchar2_table(432) := '0D0A2020202020202F2F2050726976617465206D6574686F64730D0A2020202020202F2F202D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A20200D0A2020202020202F2F2052657475726E732074686520636172657427732072656C617469766520706F7369';
wwv_flow_api.g_varchar2_table(433) := '74696F6E2066726F6D2074686520636F6E74656E746564697461626C6527730D0A2020202020202F2F206C65667420746F7020636F726E65722E0D0A2020202020202F2F0D0A2020202020202F2F204578616D706C65730D0A2020202020202F2F0D0A20';
wwv_flow_api.g_varchar2_table(434) := '20202020202F2F202020746869732E5F676574436172657452656C6174697665506F736974696F6E28290D0A2020202020202F2F2020202F2F3D3E207B20746F703A2031382C206C6566743A203230302C206C696E654865696768743A203136207D0D0A';
wwv_flow_api.g_varchar2_table(435) := '2020202020202F2F0D0A2020202020202F2F2044726F70646F776E277320706F736974696F6E2077696C6C2062652064656369646564207573696E672074686520726573756C742E0D0A2020202020205F676574436172657452656C6174697665506F73';
wwv_flow_api.g_varchar2_table(436) := '6974696F6E3A2066756E6374696F6E202829207B0D0A20202020202020207661722072616E6765203D20746869732E656C2E6F776E6572446F63756D656E742E67657453656C656374696F6E28292E67657452616E676541742830292E636C6F6E655261';
wwv_flow_api.g_varchar2_table(437) := '6E676528293B0D0A202020202020202076617220777261707065724E6F6465203D2072616E67652E656E64436F6E7461696E65722E706172656E744E6F64653B0D0A2020202020202020766172206E6F6465203D20746869732E656C2E6F776E6572446F';
wwv_flow_api.g_varchar2_table(438) := '63756D656E742E637265617465456C656D656E7428277370616E27293B0D0A202020202020202072616E67652E696E736572744E6F6465286E6F6465293B0D0A202020202020202072616E67652E73656C6563744E6F6465436F6E74656E7473286E6F64';
wwv_flow_api.g_varchar2_table(439) := '65293B0D0A202020202020202072616E67652E64656C657465436F6E74656E747328293B0D0A202020202020202073657454696D656F75742866756E6374696F6E2829207B20777261707065724E6F64652E6E6F726D616C697A6528293B207D2C203029';
wwv_flow_api.g_varchar2_table(440) := '3B0D0A202020202020202076617220246E6F6465203D2024286E6F6465293B0D0A202020202020202076617220706F736974696F6E203D20246E6F64652E6F666673657428293B0D0A2020202020202020706F736974696F6E2E6C656674202D3D207468';
wwv_flow_api.g_varchar2_table(441) := '69732E24656C2E6F666673657428292E6C6566743B0D0A2020202020202020706F736974696F6E2E746F70202B3D20246E6F64652E6865696768742829202D20746869732E24656C2E6F666673657428292E746F703B0D0A2020202020202020706F7369';
wwv_flow_api.g_varchar2_table(442) := '74696F6E2E6C696E65486569676874203D20246E6F64652E68656967687428293B0D0A20202020202020200D0A20202020202020202F2F207370656369616C20706F736974696F6E696E67206C6F67696320666F7220696672616D65730D0A2020202020';
wwv_flow_api.g_varchar2_table(443) := '2020202F2F2074686973206973207479706963616C6C79207573656420666F7220636F6E74656E746564697461626C657320737563682061732074696E796D6365206F7220636B656469746F720D0A202020202020202069662028746869732E636F6D70';
wwv_flow_api.g_varchar2_table(444) := '6C657465722E24696672616D6529207B0D0A2020202020202020202076617220696672616D65506F736974696F6E203D20746869732E636F6D706C657465722E24696672616D652E6F666673657428293B0D0A20202020202020202020706F736974696F';
wwv_flow_api.g_varchar2_table(445) := '6E2E746F70202B3D20696672616D65506F736974696F6E2E746F703B0D0A20202020202020202020706F736974696F6E2E6C656674202B3D20696672616D65506F736974696F6E2E6C6566743B0D0A202020202020202020202F2F205765206E65656420';
wwv_flow_api.g_varchar2_table(446) := '746F2067657420746865207363726F6C6C546F70206F66207468652068746D6C2D656C656D656E7420696E736964652074686520696672616D6520616E64206E6F74206F662074686520626F64792D656C656D656E742C0D0A202020202020202020202F';
wwv_flow_api.g_varchar2_table(447) := '2F2062656361757365206F6E20494520746865207363726F6C6C546F70206F662074686520626F64792D656C656D656E742028746869732E24656C2920697320616C77617973207A65726F2E0D0A20202020202020202020706F736974696F6E2E746F70';
wwv_flow_api.g_varchar2_table(448) := '202D3D202428746869732E636F6D706C657465722E24696672616D655B305D2E636F6E74656E7457696E646F772E646F63756D656E74292E7363726F6C6C546F7028293B0D0A20202020202020207D0D0A20202020202020200D0A202020202020202024';
wwv_flow_api.g_varchar2_table(449) := '6E6F64652E72656D6F766528293B0D0A202020202020202072657475726E20706F736974696F6E3B0D0A2020202020207D2C0D0A20200D0A2020202020202F2F2052657475726E732074686520737472696E67206265747765656E207468652066697273';
wwv_flow_api.g_varchar2_table(450) := '742063686172616374657220616E64207468652063617265742E0D0A2020202020202F2F20436F6D706C657465722077696C6C2062652074726967676572656420776974682074686520726573756C7420666F72207374617274206175746F636F6D706C';
wwv_flow_api.g_varchar2_table(451) := '6574696E672E0D0A2020202020202F2F0D0A2020202020202F2F204578616D706C650D0A2020202020202F2F0D0A2020202020202F2F2020202F2F20537570706F7365207468652068746D6C20697320273C623E68656C6C6F3C2F623E20776F727C6C64';
wwv_flow_api.g_varchar2_table(452) := '2720616E64207C206973207468652063617265742E0D0A2020202020202F2F202020746869732E6765745465787446726F6D48656164546F436172657428290D0A2020202020202F2F2020202F2F203D3E202720776F722720202F2F206E6F7420273C62';
wwv_flow_api.g_varchar2_table(453) := '3E68656C6C6F3C2F623E20776F72270D0A2020202020206765745465787446726F6D48656164546F43617265743A2066756E6374696F6E202829207B0D0A20202020202020207661722072616E6765203D20746869732E656C2E6F776E6572446F63756D';
wwv_flow_api.g_varchar2_table(454) := '656E742E67657453656C656374696F6E28292E67657452616E676541742830293B0D0A20202020202020207661722073656C656374696F6E203D2072616E67652E636C6F6E6552616E676528293B0D0A202020202020202073656C656374696F6E2E7365';
wwv_flow_api.g_varchar2_table(455) := '6C6563744E6F6465436F6E74656E74732872616E67652E7374617274436F6E7461696E6572293B0D0A202020202020202072657475726E2073656C656374696F6E2E746F537472696E6728292E737562737472696E6728302C2072616E67652E73746172';
wwv_flow_api.g_varchar2_table(456) := '744F6666736574293B0D0A2020202020207D0D0A202020207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E436F6E74656E744564697461626C65203D20436F6E74656E744564697461626C653B0D0A20207D286A51756572';
wwv_flow_api.g_varchar2_table(457) := '79293B0D0A20200D0A20202F2F204E4F54453A2054657874436F6D706C65746520706C7567696E2068617320636F6E74656E746564697461626C6520737570706F72742062757420697420646F6573206E6F7420776F726B0D0A20202F2F202020202020';
wwv_flow_api.g_varchar2_table(458) := '2066696E6520657370656369616C6C79206F6E206F6C64204945732E0D0A20202F2F20202020202020416E792070756C6C20726571756573747320617265205245414C4C592077656C636F6D652E0D0A20200D0A20202B66756E6374696F6E2028242920';
wwv_flow_api.g_varchar2_table(459) := '7B0D0A202020202775736520737472696374273B0D0A20200D0A202020202F2F20434B456469746F7220616461707465720D0A202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0D0A202020202F2F0D0A202020202F2F204164';
wwv_flow_api.g_varchar2_table(460) := '617074657220666F7220434B456469746F722C206261736564206F6E20636F6E74656E746564697461626C6520656C656D656E74732E0D0A2020202066756E6374696F6E20434B456469746F722028656C656D656E742C20636F6D706C657465722C206F';
wwv_flow_api.g_varchar2_table(461) := '7074696F6E29207B0D0A202020202020746869732E696E697469616C697A6528656C656D656E742C20636F6D706C657465722C206F7074696F6E293B0D0A202020207D0D0A20200D0A20202020242E657874656E6428434B456469746F722E70726F746F';
wwv_flow_api.g_varchar2_table(462) := '747970652C20242E666E2E74657874636F6D706C6574652E436F6E74656E744564697461626C652E70726F746F747970652C207B0D0A2020202020205F62696E644576656E74733A2066756E6374696F6E202829207B0D0A202020202020202076617220';
wwv_flow_api.g_varchar2_table(463) := '2474686973203D20746869733B0D0A2020202020202020746869732E6F7074696F6E2E636B656469746F725F696E7374616E63652E6F6E28276B6579272C2066756E6374696F6E286576656E7429207B0D0A2020202020202020202076617220646F6D45';
wwv_flow_api.g_varchar2_table(464) := '76656E74203D206576656E742E646174613B0D0A2020202020202020202024746869732E5F6F6E4B6579757028646F6D4576656E74293B0D0A202020202020202020206966202824746869732E636F6D706C657465722E64726F70646F776E2E73686F77';
wwv_flow_api.g_varchar2_table(465) := '6E2026262024746869732E5F736B697053656172636828646F6D4576656E742929207B0D0A20202020202020202020202072657475726E2066616C73653B0D0A202020202020202020207D0D0A20202020202020207D2C206E756C6C2C206E756C6C2C20';
wwv_flow_api.g_varchar2_table(466) := '31293B202F2F2031203D205072696F72697479203D20496D706F7274616E74210D0A20202020202020202F2F2077652061637475616C6C7920616C736F206E65656420746865206E6174697665206576656E742C2061732074686520434B456469746F72';
wwv_flow_api.g_varchar2_table(467) := '206F6E652069732068617070656E696E6720746F206C6174650D0A2020202020202020746869732E24656C2E6F6E28276B657975702E27202B20746869732E69642C20242E70726F787928746869732E5F6F6E4B657975702C207468697329293B0D0A20';
wwv_flow_api.g_varchar2_table(468) := '20202020207D2C0D0A20207D293B0D0A20200D0A20202020242E666E2E74657874636F6D706C6574652E434B456469746F72203D20434B456469746F723B0D0A20207D286A5175657279293B0D0A20200D0A20202F2F20546865204D4954204C6963656E';
wwv_flow_api.g_varchar2_table(469) := '736520284D4954290D0A20202F2F200D0A20202F2F20436F70797269676874202863292032303135204A6F6E617468616E204F6E67206D65406A6F6E676C6562657272792E636F6D0D0A20202F2F200D0A20202F2F205065726D697373696F6E20697320';
wwv_flow_api.g_varchar2_table(470) := '686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F7079206F66207468697320736F66747761726520616E640D0A20202F2F206173736F636961746564';
wwv_flow_api.g_varchar2_table(471) := '20646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C20696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C0D0A20202F2F20696E636C7564696E6720';
wwv_flow_api.g_varchar2_table(472) := '776974686F7574206C696D69746174696F6E207468652072696768747320746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C0D0A20202F2F207375626C6963656E73652C20616E';
wwv_flow_api.g_varchar2_table(473) := '642F6F722073656C6C20636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F6674776172652069730D0A20202F2F206675726E697368656420746F2064';
wwv_flow_api.g_varchar2_table(474) := '6F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A20202F2F200D0A20202F2F205468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D69737369';
wwv_flow_api.g_varchar2_table(475) := '6F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C20636F70696573206F720D0A20202F2F207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A20202F2F200D0A20202F';
wwv_flow_api.g_varchar2_table(476) := '2F2054484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F5220494D504C4945442C20494E434C5544494E47204255540D';
wwv_flow_api.g_varchar2_table(477) := '0A20202F2F204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C204649544E45535320464F52204120504152544943554C415220505552504F534520414E440D0A20202F2F204E';
wwv_flow_api.g_varchar2_table(478) := '4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C2054484520415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C0D0A20202F2F204441';
wwv_flow_api.g_varchar2_table(479) := '4D41474553204F52204F54484552204C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0D0A20202F2F204F';
wwv_flow_api.g_varchar2_table(480) := '5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E2054484520534F4654574152452E0D0A20202F2F0D0A20202F2F2068';
wwv_flow_api.g_varchar2_table(481) := '747470733A2F2F6769746875622E636F6D2F636F6D706F6E656E742F74657874617265612D63617265742D706F736974696F6E0D0A20200D0A20202866756E6374696F6E20282429207B0D0A20200D0A20202F2F205468652070726F7065727469657320';
wwv_flow_api.g_varchar2_table(482) := '7468617420776520636F707920696E746F2061206D6972726F726564206469762E0D0A20202F2F204E6F7465207468617420736F6D652062726F77736572732C20737563682061732046697265666F782C0D0A20202F2F20646F206E6F7420636F6E6361';
wwv_flow_api.g_varchar2_table(483) := '74656E6174652070726F706572746965732C20692E652E2070616464696E672D746F702C20626F74746F6D206574632E202D3E2070616464696E672C0D0A20202F2F20736F207765206861766520746F20646F2065766572792073696E676C652070726F';
wwv_flow_api.g_varchar2_table(484) := '7065727479207370656369666963616C6C792E0D0A20207661722070726F70657274696573203D205B0D0A2020202027646972656374696F6E272C20202F2F2052544C20737570706F72740D0A2020202027626F7853697A696E67272C0D0A2020202027';
wwv_flow_api.g_varchar2_table(485) := '7769647468272C20202F2F206F6E204368726F6D6520616E642049452C206578636C75646520746865207363726F6C6C6261722C20736F20746865206D6972726F72206469762077726170732065786163746C7920617320746865207465787461726561';
wwv_flow_api.g_varchar2_table(486) := '20646F65730D0A2020202027686569676874272C0D0A20202020276F766572666C6F7758272C0D0A20202020276F766572666C6F7759272C20202F2F20636F707920746865207363726F6C6C62617220666F722049450D0A20200D0A2020202027626F72';
wwv_flow_api.g_varchar2_table(487) := '646572546F705769647468272C0D0A2020202027626F7264657252696768745769647468272C0D0A2020202027626F72646572426F74746F6D5769647468272C0D0A2020202027626F726465724C6566745769647468272C0D0A2020202027626F726465';
wwv_flow_api.g_varchar2_table(488) := '725374796C65272C0D0A20200D0A202020202770616464696E67546F70272C0D0A202020202770616464696E675269676874272C0D0A202020202770616464696E67426F74746F6D272C0D0A202020202770616464696E674C656674272C0D0A20200D0A';
wwv_flow_api.g_varchar2_table(489) := '202020202F2F2068747470733A2F2F646576656C6F7065722E6D6F7A696C6C612E6F72672F656E2D55532F646F63732F5765622F4353532F666F6E740D0A2020202027666F6E745374796C65272C0D0A2020202027666F6E7456617269616E74272C0D0A';
wwv_flow_api.g_varchar2_table(490) := '2020202027666F6E74576569676874272C0D0A2020202027666F6E7453747265746368272C0D0A2020202027666F6E7453697A65272C0D0A2020202027666F6E7453697A6541646A757374272C0D0A20202020276C696E65486569676874272C0D0A2020';
wwv_flow_api.g_varchar2_table(491) := '202027666F6E7446616D696C79272C0D0A20200D0A202020202774657874416C69676E272C0D0A2020202027746578745472616E73666F726D272C0D0A202020202774657874496E64656E74272C0D0A2020202027746578744465636F726174696F6E27';
wwv_flow_api.g_varchar2_table(492) := '2C20202F2F206D69676874206E6F74206D616B65206120646966666572656E63652C206275742062657474657220626520736166650D0A20200D0A20202020276C657474657253706163696E67272C0D0A2020202027776F726453706163696E67272C0D';
wwv_flow_api.g_varchar2_table(493) := '0A20200D0A202020202774616253697A65272C0D0A20202020274D6F7A54616253697A65270D0A20200D0A20205D3B0D0A20200D0A202076617220697342726F77736572203D2028747970656F662077696E646F7720213D3D2027756E646566696E6564';
wwv_flow_api.g_varchar2_table(494) := '27293B0D0A202076617220697346697265666F78203D2028697342726F777365722026262077696E646F772E6D6F7A496E6E657253637265656E5820213D206E756C6C293B0D0A20200D0A202066756E6374696F6E206765744361726574436F6F726469';
wwv_flow_api.g_varchar2_table(495) := '6E6174657328656C656D656E742C20706F736974696F6E2C206F7074696F6E7329207B0D0A2020202069662821697342726F7773657229207B0D0A2020202020207468726F77206E6577204572726F72282774657874617265612D63617265742D706F73';
wwv_flow_api.g_varchar2_table(496) := '6974696F6E236765744361726574436F6F7264696E617465732073686F756C64206F6E6C792062652063616C6C656420696E20612062726F7773657227293B0D0A202020207D0D0A20200D0A20202020766172206465627567203D206F7074696F6E7320';
wwv_flow_api.g_varchar2_table(497) := '2626206F7074696F6E732E6465627567207C7C2066616C73653B0D0A2020202069662028646562756729207B0D0A20202020202076617220656C203D20646F63756D656E742E717565727953656C6563746F72282723696E7075742D7465787461726561';
wwv_flow_api.g_varchar2_table(498) := '2D63617265742D706F736974696F6E2D6D6972726F722D64697627293B0D0A2020202020206966202820656C2029207B20656C2E706172656E744E6F64652E72656D6F76654368696C6428656C293B207D0D0A202020207D0D0A20200D0A202020202F2F';
wwv_flow_api.g_varchar2_table(499) := '206D6972726F726564206469760D0A2020202076617220646976203D20646F63756D656E742E637265617465456C656D656E74282764697627293B0D0A202020206469762E6964203D2027696E7075742D74657874617265612D63617265742D706F7369';
wwv_flow_api.g_varchar2_table(500) := '74696F6E2D6D6972726F722D646976273B0D0A20202020646F63756D656E742E626F64792E617070656E644368696C6428646976293B0D0A20200D0A20202020766172207374796C65203D206469762E7374796C653B0D0A2020202076617220636F6D70';
wwv_flow_api.g_varchar2_table(501) := '75746564203D2077696E646F772E676574436F6D70757465645374796C653F20676574436F6D70757465645374796C6528656C656D656E7429203A20656C656D656E742E63757272656E745374796C653B20202F2F2063757272656E745374796C652066';
wwv_flow_api.g_varchar2_table(502) := '6F72204945203C20390D0A20200D0A202020202F2F2064656661756C74207465787461726561207374796C65730D0A202020207374796C652E77686974655370616365203D20277072652D77726170273B0D0A2020202069662028656C656D656E742E6E';
wwv_flow_api.g_varchar2_table(503) := '6F64654E616D6520213D3D2027494E50555427290D0A2020202020207374796C652E776F726457726170203D2027627265616B2D776F7264273B20202F2F206F6E6C7920666F722074657874617265612D730D0A20200D0A202020202F2F20706F736974';
wwv_flow_api.g_varchar2_table(504) := '696F6E206F66662D73637265656E0D0A202020207374796C652E706F736974696F6E203D20276162736F6C757465273B20202F2F20726571756972656420746F2072657475726E20636F6F7264696E617465732070726F7065726C790D0A202020206966';
wwv_flow_api.g_varchar2_table(505) := '2028216465627567290D0A2020202020207374796C652E7669736962696C697479203D202768696464656E273B20202F2F206E6F742027646973706C61793A206E6F6E652720626563617573652077652077616E742072656E646572696E670D0A20200D';
wwv_flow_api.g_varchar2_table(506) := '0A202020202F2F207472616E736665722074686520656C656D656E7427732070726F7065727469657320746F20746865206469760D0A2020202070726F706572746965732E666F72456163682866756E6374696F6E202870726F7029207B0D0A20202020';
wwv_flow_api.g_varchar2_table(507) := '20207374796C655B70726F705D203D20636F6D70757465645B70726F705D3B0D0A202020207D293B0D0A20200D0A2020202069662028697346697265666F7829207B0D0A2020202020202F2F2046697265666F78206C6965732061626F75742074686520';
wwv_flow_api.g_varchar2_table(508) := '6F766572666C6F772070726F706572747920666F72207465787461726561733A2068747470733A2F2F6275677A696C6C612E6D6F7A696C6C612E6F72672F73686F775F6275672E6367693F69643D3938343237350D0A20202020202069662028656C656D';
wwv_flow_api.g_varchar2_table(509) := '656E742E7363726F6C6C486569676874203E207061727365496E7428636F6D70757465642E68656967687429290D0A20202020202020207374796C652E6F766572666C6F7759203D20277363726F6C6C273B0D0A202020207D20656C7365207B0D0A2020';
wwv_flow_api.g_varchar2_table(510) := '202020207374796C652E6F766572666C6F77203D202768696464656E273B20202F2F20666F72204368726F6D6520746F206E6F742072656E6465722061207363726F6C6C6261723B204945206B65657073206F766572666C6F7759203D20277363726F6C';
wwv_flow_api.g_varchar2_table(511) := '6C270D0A202020207D0D0A20200D0A202020206469762E74657874436F6E74656E74203D20656C656D656E742E76616C75652E737562737472696E6728302C20706F736974696F6E293B0D0A202020202F2F20746865207365636F6E6420737065636961';
wwv_flow_api.g_varchar2_table(512) := '6C2068616E646C696E6720666F7220696E70757420747970653D2274657874222076732074657874617265613A20737061636573206E65656420746F206265207265706C616365642077697468206E6F6E2D627265616B696E6720737061636573202D20';
wwv_flow_api.g_varchar2_table(513) := '687474703A2F2F737461636B6F766572666C6F772E636F6D2F612F31333430323033352F313236393033370D0A2020202069662028656C656D656E742E6E6F64654E616D65203D3D3D2027494E50555427290D0A2020202020206469762E74657874436F';
wwv_flow_api.g_varchar2_table(514) := '6E74656E74203D206469762E74657874436F6E74656E742E7265706C616365282F5C732F672C20275C753030613027293B0D0A20200D0A20202020766172207370616E203D20646F63756D656E742E637265617465456C656D656E7428277370616E2729';
wwv_flow_api.g_varchar2_table(515) := '3B0D0A202020202F2F205772617070696E67206D757374206265207265706C696361746564202A65786163746C792A2C20696E636C7564696E67207768656E2061206C6F6E6720776F726420676574730D0A202020202F2F206F6E746F20746865206E65';
wwv_flow_api.g_varchar2_table(516) := '7874206C696E652C207769746820776869746573706163652061742074686520656E64206F6620746865206C696E65206265666F726520282337292E0D0A202020202F2F2054686520202A6F6E6C792A2072656C6961626C652077617920746F20646F20';
wwv_flow_api.g_varchar2_table(517) := '7468617420697320746F20636F707920746865202A656E746972652A2072657374206F66207468650D0A202020202F2F207465787461726561277320636F6E74656E7420696E746F20746865203C7370616E3E2063726561746564206174207468652063';
wwv_flow_api.g_varchar2_table(518) := '6172657420706F736974696F6E2E0D0A202020202F2F20666F7220696E707574732C206A75737420272E2720776F756C6420626520656E6F7567682C206275742077687920626F746865723F0D0A202020207370616E2E74657874436F6E74656E74203D';
wwv_flow_api.g_varchar2_table(519) := '20656C656D656E742E76616C75652E737562737472696E6728706F736974696F6E29207C7C20272E273B20202F2F207C7C2062656361757365206120636F6D706C6574656C7920656D7074792066617578207370616E20646F65736E27742072656E6465';
wwv_flow_api.g_varchar2_table(520) := '7220617420616C6C0D0A202020206469762E617070656E644368696C64287370616E293B0D0A20200D0A2020202076617220636F6F7264696E61746573203D207B0D0A202020202020746F703A207370616E2E6F6666736574546F70202B207061727365';
wwv_flow_api.g_varchar2_table(521) := '496E7428636F6D70757465645B27626F72646572546F705769647468275D292C0D0A2020202020206C6566743A207370616E2E6F66667365744C656674202B207061727365496E7428636F6D70757465645B27626F726465724C6566745769647468275D';
wwv_flow_api.g_varchar2_table(522) := '290D0A202020207D3B0D0A20200D0A2020202069662028646562756729207B0D0A2020202020207370616E2E7374796C652E6261636B67726F756E64436F6C6F72203D202723616161273B0D0A202020207D20656C7365207B0D0A202020202020646F63';
wwv_flow_api.g_varchar2_table(523) := '756D656E742E626F64792E72656D6F76654368696C6428646976293B0D0A202020207D0D0A20200D0A2020202072657475726E20636F6F7264696E617465733B0D0A20207D0D0A20200D0A2020242E666E2E74657874636F6D706C6574652E6765744361';
wwv_flow_api.g_varchar2_table(524) := '726574436F6F7264696E61746573203D206765744361726574436F6F7264696E617465733B0D0A20200D0A20207D286A517565727929293B0D0A20200D0A202072657475726E206A51756572793B0D0A20207D29293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(40390321065734081773)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/jquery-textcomplete.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22434F4D4D454E5453222C22696E697469616C697A65222C22636F6E666967222C22696E6974222C2272656769';
wwv_flow_api.g_varchar2_table(2) := '6F6E4964222C2266756E6374696F6E616C6974696573222C22636F6D6D656E74735769746850696E6773222C2261646450696E67734A534F4E222C22636F6D6D656E7473222C2270696E67696E674C697374222C22636667222C22656E61626C65557076';
wwv_flow_api.g_varchar2_table(3) := '6F74696E67222C22656E61626C655265706C79696E67222C22656E61626C6544656C6574696E67222C22656E61626C6544656C6574696E67436F6D6D656E74576974685265706C696573222C22656E61626C6545646974696E67222C22656E61626C6550';
wwv_flow_api.g_varchar2_table(4) := '696E67696E67222C22676574436F6D6D656E7473222C2273756363657373222C226572726F72222C227365617263685573657273222C227465726D222C2266696C74657250696E67734C697374222C22706F7374436F6D6D656E74222C22636F6D6D656E';
wwv_flow_api.g_varchar2_table(5) := '744A534F4E222C2261706578222C22736572766572222C22706C7567696E222C22616A61784964656E746966696572222C22783031222C22783032222C226964222C22783033222C22706172656E74222C22783034222C22636F6E74656E74222C227830';
wwv_flow_api.g_varchar2_table(6) := '35222C2266756C6C6E616D65222C22783036222C2264617461222C22636F6E736F6C65222C226C6F67222C226A71584852222C2274657874537461747573222C226572726F725468726F776E222C226D657373616765222C22616C657274222C22726573';
wwv_flow_api.g_varchar2_table(7) := '706F6E73654A534F4E222C2264656C657465436F6D6D656E74222C22697350726F636573735375636365737366756C6C7946696E69686564222C22707574436F6D6D656E74222C2263616C6C222C2274686973222C22726567696F6E222C226372656174';
wwv_flow_api.g_varchar2_table(8) := '65222C2274797065222C2224222C2266696E64222C2261747472222C2263726561746550696E67696E676C6973744A534F4E222C2275736572734172726179222C226C697374222C22666F7245616368222C226F626A222C2270696E6773222C2270696E';
wwv_flow_api.g_varchar2_table(9) := '6773496E537472696E67222C2267657450696E6773496E537472696E67222C2266696C746572222C2270222C22696E636C75646573222C22737472222C227265706C616365416C6C222C2273706C6974222C226D6170222C224E756D626572222C226E61';
wwv_flow_api.g_varchar2_table(10) := '6D65222C226E222C22526567457870222C22746F557070657243617365222C226C222C226D61746368225D2C226D617070696E6773223A2241414341412C4F41414F432C53414157442C4F41414F432C554141592C4741477243412C53414153432C5741';
wwv_flow_api.g_varchar2_table(11) := '41612C53414153432C45414151432C4741456E432C49414149432C45414157462C4541414F472C674241416742442C5341436C43452C4541416F424E2C534141534F2C614141614C2C4541414F4D2C534141534E2C4541414F4F2C6141436A45432C4541';
wwv_flow_api.g_varchar2_table(12) := '414D2C4341474E432C6742414167422C4541456842432C6742414167422C4541456842432C6541416742582C4541414F472C674241416742512C6541457643432C694341416B435A2C4541414F472C674241416742532C694341457A44432C6341416562';
wwv_flow_api.g_varchar2_table(13) := '2C4541414F472C674241416742552C6341457443432C63414165642C4541414F472C674241416742572C6341457443432C594141612C53414153432C45414153432C4741453342442C4541446F425A2C4941497842632C594141612C53414153432C4541';
wwv_flow_api.g_varchar2_table(14) := '414D482C45414153432C4741436A43442C454141516C422C5341415373422C67424141674270422C4541414F4F2C59414159592C4B41477844452C594141612C53414153432C454141614E2C45414153432C47414778434D2C4B41414B432C4F41414F43';
wwv_flow_api.g_varchar2_table(15) := '2C4F4141537A422C4541414F472C67424141674275422C65414167422C4341437044432C4941414B2C4941434C432C4941414B4E2C454141594F2C4741436A42432C4941414B522C45414159532C4F41436A42432C4941414B562C45414159572C514143';
wwv_flow_api.g_varchar2_table(16) := '6A42432C4941414B5A2C45414159612C5341436A42432C4941414B2C634145622C4341434970422C514141532C5341415571422C47414366432C51414151432C494141496A422C4741435A4E2C454141514D2C4941455A4C2C4D41414F2C534141557542';
wwv_flow_api.g_varchar2_table(17) := '2C4541414F432C45414159432C47414368436E422C4B41414B6F422C51414151432C4D41414D4A2C4541414D4B2C61414161462C61414D6C44472C634141652C5341415378422C454141614E2C45414153432C47414531432C4941414938422C4741412B';
wwv_flow_api.g_varchar2_table(18) := '422C4541472F422F432C4541414F472C674241416742532C6B4341437642572C4B41414B432C4F41414F432C4F4141537A422C4541414F472C67424141674275422C65414167422C4341436844432C4941414B2C4941434C432C4941414B4E2C45414159';
wwv_flow_api.g_varchar2_table(19) := '4F2C4741436A42432C4941414B522C45414159532C4F41436A42432C4941414B562C45414159572C5141436A42432C4941414B5A2C45414159612C5341436A42432C4941414B2C634145622C4341435170422C514141532C5341415571422C4741436655';
wwv_flow_api.g_varchar2_table(20) := '2C4541412B42562C4541414B72422C5341457843432C4D41414F2C5341415575422C4541414F432C45414159432C47414368434B2C4741412B422C4541432F4278422C4B41414B6F422C51414151432C4D41414D4A2C4541414D4B2C61414161462C6141';
wwv_flow_api.g_varchar2_table(21) := '4D724433432C4541414F472C674241416742532C6B4341416F436D432C474143354478422C4B41414B432C4F41414F432C4F4141537A422C4541414F472C67424141674275422C65414167422C4341437044432C4941414B2C4941434C432C4941414B4E';
wwv_flow_api.g_varchar2_table(22) := '2C454141594F2C4741436A42432C4941414B522C45414159532C4F41436A42432C4941414B562C45414159572C5141436A42432C4941414B5A2C45414159612C5341436A42432C4941414B2C634145622C4341434970422C514141532C5341415571422C';
wwv_flow_api.g_varchar2_table(23) := '47414366552C4541412B42562C4541414B72422C5341457843432C4D41414F2C5341415575422C4541414F432C45414159432C47414368434B2C4741412B422C4541432F4278422C4B41414B6F422C51414151432C4D41414D4A2C4541414D4B2C614141';
wwv_flow_api.g_varchar2_table(24) := '61462C61414D374333432C4541414F472C674241416742532C6B4341416F436D432C474143354478422C4B41414B432C4F41414F432C4F4141537A422C4541414F472C67424141674275422C65414167422C4341437044432C4941414B2C4941434C432C';
wwv_flow_api.g_varchar2_table(25) := '4941414B4E2C454141594F2C4741436A42432C4941414B522C45414159532C4F41436A42432C4941414B562C45414159572C5141436A42432C4941414B5A2C45414159612C5341436A42432C4941414B2C634145622C4341434970422C514141532C5341';
wwv_flow_api.g_varchar2_table(26) := '415571422C47414366552C4541412B42562C4541414B72422C5341457843432C4D41414F2C5341415575422C4541414F432C45414159432C47414368436E422C4B41414B6F422C51414151432C4D41414D4A2C4541414D4B2C61414161462C59414D3943';
wwv_flow_api.g_varchar2_table(27) := '492C47414138422F422C454141514D2C494149394330422C574141592C5341415331422C454141614E2C45414153432C47414776434D2C4B41414B432C4F41414F432C4F4141537A422C4541414F472C67424141674275422C65414167422C4341437044';
wwv_flow_api.g_varchar2_table(28) := '432C4941414B2C4941434C432C4941414B4E2C454141594F2C4741436A42432C4941414B522C45414159532C4F41436A42432C4941414B562C45414159572C5141436A42432C4941414B5A2C45414159612C5341436A42432C4941414B2C634145622C43';
wwv_flow_api.g_varchar2_table(29) := '41434970422C514141532C5341415571422C4741436672422C454141514D2C4941455A4C2C4D41414F2C5341415575422C4541414F432C45414159432C47414368436E422C4B41414B6F422C51414151432C4D41414D4A2C4541414D4B2C61414161462C';
wwv_flow_api.g_varchar2_table(30) := '59414B394333422C454141514D2C4B414D5A72422C47414175422C6D42414152412C4741416F42412C4541414B67442C4B41414B432C4B41414D6C442C474147764475422C4B41414B34422C4F41414F432C4F41414F6C442C454141552C4341437A426D';
wwv_flow_api.g_varchar2_table(31) := '442C4B41414D2C7942414956432C454141452C4941414D70442C47414155492C53414153452C474147334238432C454141452C4941414D70442C4741415571442C4B41414B2C674241416742432C4B41414B2C4F41414F2C57414B764431442C53414153';
wwv_flow_api.g_varchar2_table(32) := '32442C7342414177422C53414153432C47414374432C49414149432C4541414F2C47414D582C4F414A41442C45414157452C534141512C53414153432C4741437842462C4541414B452C4541414968432C4941414D67432C4541414931422C5941476842';
wwv_flow_api.g_varchar2_table(33) := '77422C4741495837442C534141534F2C614141652C5341415371442C45414157492C47414378432C49414149432C45414F4A2C4F414C414C2C45414157452C534141512C53414153432C4741437842452C45414167426A452C534141536B452C69424141';
wwv_flow_api.g_varchar2_table(34) := '6942482C4541414935422C534143394334422C45414149432C4D41415168452C5341415332442C7342414173424B2C4541414D472C5141414F432C4741414B482C45414163492C53414153442C4541414572432C5541476E4636422C4741495835442C53';
wwv_flow_api.g_varchar2_table(35) := '4141536B452C694241416D422C53414153492C4741456A432C4F41414F412C45414149432C574144472C554143632C49414149432C4D41414D2C4B41414B432C49414149432C5341496E4431452C5341415373422C674241416B422C5341415375432C45';
wwv_flow_api.g_varchar2_table(36) := '41414B632C47414372432C49414149432C454141492C49414149432C4F41414F462C4541414B472C65414378422C4F41414F6A422C4541414B4D2C5141414F592C4741414B412C4541414531432C5341415379432C63414163452C4D41414D4A222C2266';
wwv_flow_api.g_varchar2_table(37) := '696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(41157548388474727169)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B226A71756572792D636F6D6D656E74732E6A73225D2C226E616D6573223A5B22666163746F7279222C22646566696E65222C22616D64222C226D6F64756C65222C226578706F727473222C22';
wwv_flow_api.g_varchar2_table(2) := '726F6F74222C226A5175657279222C22756E646566696E6564222C2277696E646F77222C2272657175697265222C2224222C22436F6D6D656E7473222C2224656C222C22636F6D6D656E747342794964222C226461746146657463686564222C22637572';
wwv_flow_api.g_varchar2_table(3) := '72656E74536F72744B6579222C226F7074696F6E73222C226576656E7473222C22636C69636B222C227061737465222C2264726167656E746572222C2267657444656661756C744F7074696F6E73222C2270726F66696C655069637475726555524C222C';
wwv_flow_api.g_varchar2_table(4) := '2263757272656E7455736572497341646D696E222C2263757272656E74557365724964222C227370696E6E657249636F6E55524C222C227570766F746549636F6E55524C222C227265706C7949636F6E55524C222C2275706C6F616449636F6E55524C22';
wwv_flow_api.g_varchar2_table(5) := '2C226174746163686D656E7449636F6E55524C222C226E6F436F6D6D656E747349636F6E55524C222C22636C6F736549636F6E55524C222C227465787461726561506C616365686F6C64657254657874222C226E657765737454657874222C226F6C6465';
wwv_flow_api.g_varchar2_table(6) := '737454657874222C22706F70756C617254657874222C226174746163686D656E747354657874222C2273656E6454657874222C227265706C7954657874222C226564697454657874222C2265646974656454657874222C22796F7554657874222C227361';
wwv_flow_api.g_varchar2_table(7) := '766554657874222C2264656C65746554657874222C226E657754657874222C2276696577416C6C5265706C69657354657874222C22686964655265706C69657354657874222C226E6F436F6D6D656E747354657874222C226E6F4174746163686D656E74';
wwv_flow_api.g_varchar2_table(8) := '7354657874222C226174746163686D656E7444726F7054657874222C2274657874466F726D6174746572222C2274657874222C22656E61626C655265706C79696E67222C22656E61626C6545646974696E67222C22656E61626C655570766F74696E6722';
wwv_flow_api.g_varchar2_table(9) := '2C22656E61626C6544656C6574696E67222C22656E61626C654174746163686D656E7473222C22656E61626C654861736874616773222C22656E61626C6550696E67696E67222C22656E61626C6544656C6574696E67436F6D6D656E7457697468526570';
wwv_flow_api.g_varchar2_table(10) := '6C696573222C22656E61626C654E617669676174696F6E222C22706F7374436F6D6D656E744F6E456E746572222C22666F726365526573706F6E73697665222C22726561644F6E6C79222C2264656661756C744E617669676174696F6E536F72744B6579';
wwv_flow_api.g_varchar2_table(11) := '222C22686967686C69676874436F6C6F72222C2264656C657465427574746F6E436F6C6F72222C227363726F6C6C436F6E7461696E6572222C2274686973222C22726F756E6450726F66696C655069637475726573222C227465787461726561526F7773';
wwv_flow_api.g_varchar2_table(12) := '222C227465787461726561526F77734F6E466F637573222C2274657874617265614D6178526F7773222C226D61785265706C69657356697369626C65222C226669656C644D617070696E6773222C226964222C22706172656E74222C2263726561746564';
wwv_flow_api.g_varchar2_table(13) := '222C226D6F646966696564222C22636F6E74656E74222C226174746163686D656E7473222C2270696E6773222C2263726561746F72222C2266756C6C6E616D65222C2269734E6577222C2263726561746564427941646D696E222C226372656174656442';
wwv_flow_api.g_varchar2_table(14) := '7943757272656E7455736572222C227570766F7465436F756E74222C22757365724861735570766F746564222C227365617263685573657273222C227465726D222C2273756363657373222C226572726F72222C22676574436F6D6D656E7473222C2270';
wwv_flow_api.g_varchar2_table(15) := '6F7374436F6D6D656E74222C22636F6D6D656E744A534F4E222C22707574436F6D6D656E74222C2264656C657465436F6D6D656E74222C227570766F7465436F6D6D656E74222C2276616C69646174654174746163686D656E7473222C2263616C6C6261';
wwv_flow_api.g_varchar2_table(16) := '636B222C2268617368746167436C69636B6564222C2268617368746167222C2270696E67436C69636B6564222C22757365724964222C2272656672657368222C2274696D65466F726D6174746572222C2274696D65222C2244617465222C22746F4C6F63';
wwv_flow_api.g_varchar2_table(17) := '616C6544617465537472696E67222C22696E6974222C22656C222C2261222C22616464436C617373222C22756E64656C65676174654576656E7473222C2264656C65676174654576656E7473222C226E6176696761746F72222C22757365724167656E74';
wwv_flow_api.g_varchar2_table(18) := '222C2276656E646F72222C226F70657261222C2262726F77736572222C226D6F62696C65222C2274657374222C22737562737472222C22657874656E64222C226372656174654373734465636C61726174696F6E73222C22666574636844617461416E64';
wwv_flow_api.g_varchar2_table(19) := '52656E646572222C2262696E644576656E7473222C22756E62696E64222C2262696E6446756E6374696F6E222C226B6579222C226576656E744E616D65222C2273706C6974222C2273656C6563746F72222C22736C696365222C226A6F696E222C226D65';
wwv_flow_api.g_varchar2_table(20) := '74686F644E616D6573222C22696E646578222C226861734F776E50726F7065727479222C226D6574686F64222C2270726F7879222C2273656C66222C22656D707479222C2263726561746548544D4C222C22636F6D6D656E74734172726179222C22636F';
wwv_flow_api.g_varchar2_table(21) := '6D6D656E744D6F64656C73222C226D6170222C22636F6D6D656E74734A534F4E222C22637265617465436F6D6D656E744D6F64656C222C22736F7274436F6D6D656E7473222C2265616368222C22636F6D6D656E744D6F64656C222C22616464436F6D6D';
wwv_flow_api.g_varchar2_table(22) := '656E74546F446174614D6F64656C222C2272656E646572222C2266657463684E657874222C227370696E6E6572222C226372656174655370696E6E6572222C2266696E64222C22617070656E64222C22637265617465436F6D6D656E74222C2272656D6F';
wwv_flow_api.g_varchar2_table(23) := '7665222C226170706C79496E7465726E616C4D617070696E6773222C226368696C6473222C226861734174746163686D656E7473222C226C656E677468222C226765744F757465726D6F7374506172656E74222C2270757368222C22757064617465436F';
wwv_flow_api.g_varchar2_table(24) := '6D6D656E744D6F64656C222C2273686F77416374697665436F6E7461696E6572222C22637265617465436F6D6D656E7473222C226372656174654174746163686D656E7473222C22636F6E7461696E65724E616D65222C2264617461222C22636F6E7461';
wwv_flow_api.g_varchar2_table(25) := '696E6572456C222C227369626C696E6773222C2268696465222C2273686F77222C22636F6D6D656E744C697374222C22636C617373222C226D61696E4C6576656C436F6D6D656E7473222C227265706C696573222C22616464436F6D6D656E74222C2270';
wwv_flow_api.g_varchar2_table(26) := '726570656E64222C226174746163686D656E744C697374222C226765744174746163686D656E7473222C226164644174746163686D656E74222C2270726570656E64436F6D6D656E74222C22636F6D6D656E74456C222C22637265617465436F6D6D656E';
wwv_flow_api.g_varchar2_table(27) := '74456C656D656E74222C22646972656374506172656E74456C222C226368696C64496E64656E64222C227061727365496E74222C22637373222C226368696C6472656E222C22726552656E646572436F6D6D656E74416374696F6E426172222C226F7574';
wwv_flow_api.g_varchar2_table(28) := '65724D6F7374506172656E74222C22706172656E7473222C226C617374222C226166746572222C22757064617465546F67676C65416C6C427574746F6E222C2272656D6F7665436F6D6D656E74222C22636F6D6D656E744964222C226368696C64436F6D';
wwv_flow_api.g_varchar2_table(29) := '6D656E7473222C226765744368696C64436F6D6D656E7473222C226368696C64436F6D6D656E74222C226F757465726D6F7374506172656E74222C22696E646578546F52656D6F7665222C22696E6465784F66222C2273706C696365222C22636F6D6D65';
wwv_flow_api.g_varchar2_table(30) := '6E74456C656D656E7473222C22706172656E74456C222C2270726544656C6574654174746163686D656E74222C226576222C22636F6D6D656E74696E674669656C64222C2263757272656E74546172676574222C226669727374222C22746F67676C6553';
wwv_flow_api.g_varchar2_table(31) := '617665427574746F6E222C22707265536176654174746163686D656E7473222C2266696C6573222C2275706C6F6164427574746F6E222C226174746163686D656E7473436F6E7461696E6572222C22686173436C617373222C2266696C65222C226D696D';
wwv_flow_api.g_varchar2_table(32) := '655F74797065222C2274797065222C226578697374696E674174746163686D656E7473222C226765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C64222C2266696C746572222C226174746163686D656E74222C226475706C';
wwv_flow_api.g_varchar2_table(33) := '6963617465222C226578697374696E674174746163686D656E74222C226E616D65222C2273697A65222C2274726967676572222C22736574427574746F6E5374617465222C2276616C6964617465644174746163686D656E7473222C226174746163686D';
wwv_flow_api.g_varchar2_table(34) := '656E74546167222C226372656174654174746163686D656E74546167456C656D656E74222C2276616C222C226368696C64436F6D6D656E7473456C222C226E6F74222C22746F67676C65416C6C427574746F6E222C2272656D6F7665436C617373222C22';
wwv_flow_api.g_varchar2_table(35) := '746F67676C61626C655265706C696573222C22746F67676C65416C6C427574746F6E54657874222C226361726574222C22736574546F67676C65416C6C427574746F6E54657874222C22757064617465546F67676C65416C6C427574746F6E73222C2263';
wwv_flow_api.g_varchar2_table(36) := '6F6D6D656E7473222C22736F72744B6579222C22736F7274222C22636F6D6D656E7441222C22636F6D6D656E7442222C22706F696E74734F6641222C22706F696E74734F6642222C226372656174656441222C2267657454696D65222C22637265617465';
wwv_flow_api.g_varchar2_table(37) := '6442222C22736F7274416E645265417272616E6765436F6D6D656E7473222C2273686F77416374697665536F7274222C22616374697665456C656D656E7473222C227469746C65456C222C2268746D6C222C2264656661756C7444726F70646F776E456C';
wwv_flow_api.g_varchar2_table(38) := '222C22636C6F736544726F70646F776E73222C22707265536176655061737465644174746163686D656E7473222C226F726967696E616C4576656E74222C22636C6970626F61726444617461222C22706172656E74436F6D6D656E74696E674669656C64';
wwv_flow_api.g_varchar2_table(39) := '222C22746172676574222C2270726576656E7444656661756C74222C22736176654F6E4B6579646F776E222C226B6579436F6465222C226D6574614B6579222C226374726C4B6579222C2273746F7050726F7061676174696F6E222C2273617665456469';
wwv_flow_api.g_varchar2_table(40) := '7461626C65436F6E74656E74222C22636865636B4564697461626C65436F6E74656E74466F724368616E6765222C226368696C644E6F646573222C226E6F646554797065222C224E6F6465222C22544558545F4E4F4445222C2272656D6F76654E6F6465';
wwv_flow_api.g_varchar2_table(41) := '222C226E617669676174696F6E456C656D656E74436C69636B6564222C22746F67676C654E617669676174696F6E44726F70646F776E222C22746F67676C65222C2273686F774D61696E436F6D6D656E74696E674669656C64222C226D61696E54657874';
wwv_flow_api.g_varchar2_table(42) := '61726561222C22666F637573222C22686964654D61696E436F6D6D656E74696E674669656C64222C22636C6F7365427574746F6E222C226D61696E436F6E74726F6C526F77222C22636C6561725465787461726561222C2261646A757374546578746172';
wwv_flow_api.g_varchar2_table(43) := '6561486569676874222C22626C7572222C22696E6372656173655465787461726561486569676874222C227465787461726561222C227465787461726561436F6E74656E744368616E676564222C2261747472222C22706172656E74436F6D6D656E7473';
wwv_flow_api.g_varchar2_table(44) := '222C22706172656E744964222C227363726F6C6C486569676874222C226F75746572486569676874222C22656E61626C6564222C2273617665427574746F6E222C226765745465787461726561436F6E74656E74222C22706172656E7446726F6D4D6F64';
wwv_flow_api.g_varchar2_table(45) := '656C222C22636F6E74656E744368616E676564222C22746F537472696E67222C22706172656E744368616E676564222C226174746163686D656E74734368616E676564222C2273617665644174746163686D656E74496473222C2263757272656E744174';
wwv_flow_api.g_varchar2_table(46) := '746163686D656E74496473222C22617265417272617973457175616C222C22426F6F6C65616E222C22746F67676C65436C617373222C2272656D6F7665436F6D6D656E74696E674669656C64222C2273656E64427574746F6E222C22637265617465436F';
wwv_flow_api.g_varchar2_table(47) := '6D6D656E744A534F4E222C226170706C7945787465726E616C4D617070696E6773222C2267657450696E6773222C22726552656E646572436F6D6D656E74222C2264656C657465427574746F6E222C2276616C7565222C2266696C65496E707574436861';
wwv_flow_api.g_varchar2_table(48) := '6E676564222C226E65775570766F7465436F756E74222C226D6F64656C222C2270726576696F75735570766F7465436F756E74222C22726552656E6465725570766F746573222C22746F67676C655265706C696573222C227265706C79427574746F6E43';
wwv_flow_api.g_varchar2_table(49) := '6C69636B6564222C227265706C79427574746F6E222C227265706C794669656C64222C22637265617465436F6D6D656E74696E674669656C64456C656D656E74222C226D6F7665437572736F72546F456E64222C22656E73757265456C656D656E745374';
wwv_flow_api.g_varchar2_table(50) := '61797356697369626C65222C2265646974427574746F6E436C69636B6564222C22656469744669656C64222C22676574466F726D6174746564436F6D6D656E74436F6E74656E74222C2273686F7744726F707061626C654F7665726C6179222C22736372';
wwv_flow_api.g_varchar2_table(51) := '6F6C6C546F70222C2268616E646C6544726167456E746572222C22636F756E74222C2268616E646C65447261674C65617665222C2268616E646C65447261674C65617665466F724F7665726C6179222C226869646544726F707061626C654F7665726C61';
wwv_flow_api.g_varchar2_table(52) := '79222C2268616E646C65447261674C65617665466F7244726F707061626C65222C2268616E646C65447261674F766572466F724F7665726C6179222C22646174615472616E73666572222C2264726F70456666656374222C2268616E646C6544726F7022';
wwv_flow_api.g_varchar2_table(53) := '2C226D61696E436F6D6D656E74696E674669656C64222C226372656174654D61696E436F6D6D656E74696E674669656C64456C656D656E74222C226372656174654E617669676174696F6E456C656D656E74222C22636F6D6D656E7473436F6E7461696E';
wwv_flow_api.g_varchar2_table(54) := '6572222C226E6F436F6D6D656E7473222C226E6F436F6D6D656E747349636F6E222C226E6F4174746163686D656E7473222C226E6F4174746163686D656E747349636F6E222C2264726F707061626C654F7665726C6179222C2264726F707061626C6543';
wwv_flow_api.g_varchar2_table(55) := '6F6E7461696E6572222C2264726F707061626C65222C2275706C6F616449636F6E222C2264726F704174746163686D656E7454657874222C2263726561746550726F66696C6550696374757265456C656D656E74222C22737263222C2270726F66696C65';
wwv_flow_api.g_varchar2_table(56) := '50696374757265222C226578697374696E67436F6D6D656E744964222C2269734D61696E222C22746578746172656157726170706572222C22636F6E74726F6C526F77222C22636F6E74656E746564697461626C65222C22637265617465436C6F736542';
wwv_flow_api.g_varchar2_table(57) := '7574746F6E222C2273617665427574746F6E436C617373222C2273617665427574746F6E54657874222C226973416C6C6F776564546F44656C657465222C2264656C657465427574746F6E54657874222C2266696C65496E707574222C226D756C746970';
wwv_flow_api.g_varchar2_table(58) := '6C65222C226D61696E55706C6F6164427574746F6E222C22636C6F6E65222C22706172656E744D6F64656C222C227265706C79546F4E616D65222C227265706C79546F546167222C22637265617465546167456C656D656E74222C2274657874636F6D70';
wwv_flow_api.g_varchar2_table(59) := '6C657465222C226D61746368222C22736561726368222C226E6F726D616C697A65537061636573222C2274656D706C617465222C2275736572222C2277726170706572222C2270726F66696C6550696374757265456C222C2270726F66696C655F706963';
wwv_flow_api.g_varchar2_table(60) := '747572655F75726C222C2264657461696C73456C222C226E616D65456C222C22656D61696C456C222C22656D61696C222C227265706C616365222C226F7574657248544D4C222C22617070656E64546F222C2264726F70646F776E436C6173734E616D65';
wwv_flow_api.g_varchar2_table(61) := '222C226D6178436F756E74222C227269676874456467654F6666736574222C226465626F756E6365222C22666E222C2244726F70646F776E222C2270726F746F74797065222C227A697070656444617461222C22636F6E74656E747348746D6C222C225F';
wwv_flow_api.g_varchar2_table(62) := '6275696C64436F6E74656E7473222C22756E7A697070656444617461222C2264222C227374726174656779222C2272656D6F766541747472222C225F72656E646572486561646572222C225F72656E646572466F6F746572222C225F72656E646572436F';
wwv_flow_api.g_varchar2_table(63) := '6E74656E7473222C225F666974546F426F74746F6D222C225F666974546F5269676874222C225F6163746976617465496E64657865644974656D222C225F7365745363726F6C6C222C226E6F526573756C74734D657373616765222C225F72656E646572';
wwv_flow_api.g_varchar2_table(64) := '4E6F526573756C74734D657373616765222C2273686F776E222C2264656163746976617465222C22746F70222C226F726967696E616C4C656674222C226D61784C656674222C227769647468222C226F757465725769647468222C226C656674222C224D';
wwv_flow_api.g_varchar2_table(65) := '617468222C226D696E222C22436F6E74656E744564697461626C65222C225F736B6970536561726368222C22636C69636B4576656E74222C226E617669676174696F6E456C222C226E617669676174696F6E57726170706572222C226E6577657374222C';
wwv_flow_api.g_varchar2_table(66) := '226F6C64657374222C22706F70756C6172222C226174746163686D656E747349636F6E222C2264726F70646F776E4E617669676174696F6E57726170706572222C2264726F70646F776E4E617669676174696F6E222C2264726F70646F776E5469746C65';
wwv_flow_api.g_varchar2_table(67) := '222C2264726F70646F776E5469746C65486561646572222C22696E6C696E65222C227370696E6E657249636F6E222C22636C6173734E616D65222C2269636F6E222C22636F6D6D656E7457726170706572222C22637265617465436F6D6D656E74577261';
wwv_flow_api.g_varchar2_table(68) := '70706572456C656D656E74222C22636F6D6D656E74486561646572456C222C227265706C79546F222C227265706C7949636F6E222C226E6577546167222C2265646974656454696D65222C22656469746564222C226174746163686D656E745072657669';
wwv_flow_api.g_varchar2_table(69) := '657773222C226174746163686D656E7454616773222C226D696D65547970655061727473222C2270726576696577526F77222C2270726576696577222C2268726566222C22696D616765222C22766964656F222C22636F6E74726F6C73222C2261637469';
wwv_flow_api.g_varchar2_table(70) := '6F6E73222C22736570617261746F72222C227265706C79222C227570766F746549636F6E222C227570766F746573222C226372656174655570766F7465456C656D656E74222C2265646974427574746F6E222C22616374696F6E456C222C226973222C22';
wwv_flow_api.g_varchar2_table(71) := '6578747261436C6173736573222C22657874726141747472696275746573222C22746167456C222C2264656C657461626C65222C2266696C654E616D65222C2246696C65222C227061727473222C226465636F6465555249436F6D706F6E656E74222C22';
wwv_flow_api.g_varchar2_table(72) := '6174746163686D656E7449636F6E222C227265706C61636557697468222C22637265617465437373222C227374796C65456C222C224F626A656374222C226B657973222C22636F6D6D656E74222C22646972656374506172656E744964222C2270617265';
wwv_flow_api.g_varchar2_table(73) := '6E74436F6D6D656E74222C22746F49534F537472696E67222C2274657874436F6E7461696E6572222C2273686F77457870616E64696E6754657874222C227265706C79436F756E74222C22627574746F6E222C226C6F6164696E67222C22686569676874';
wwv_flow_api.g_varchar2_table(74) := '222C22726F77436F756E74222C226973417265615363726F6C6C61626C65222C226D6178526F777355736564222C2268756D616E5265616461626C65222C227465787461726561436C6F6E65222C226365222C22696E6E657248544D4C222C227265706C';
wwv_flow_api.g_varchar2_table(75) := '6163654E65774C696E6573222C22657363617065222C226C696E6B696679222C22686967686C6967687454616773222C22746F4172726179222C2267657453656C656374696F6E222C22646F63756D656E74222C2263726561746552616E6765222C2272';
wwv_flow_api.g_varchar2_table(76) := '616E6765222C2273656C6563744E6F6465436F6E74656E7473222C22636F6C6C61707365222C2273656C222C2272656D6F7665416C6C52616E676573222C2261646452616E6765222C22626F6479222C226372656174655465787452616E6765222C2274';
wwv_flow_api.g_varchar2_table(77) := '65787452616E6765222C226D6F7665546F456C656D656E7454657874222C2273656C656374222C226D61785363726F6C6C546F70222C22706F736974696F6E222C226D696E5363726F6C6C546F70222C22696E70757454657874222C2252656745787022';
wwv_flow_api.g_varchar2_table(78) := '2C2274696D6573222C2266756E63222C226170706C79222C22617267756D656E7473222C22686967686C696768744861736874616773222C22686967686C6967687450696E6773222C222430222C222431222C222432222C22746167222C2270696E6754';
wwv_flow_api.g_varchar2_table(79) := '657874222C225F5F637265617465546167222C227265706C6163656454657874222C227265706C6163655061747465726E31222C227265706C6163655061747465726E32222C227265706C6163655061747465726E33222C2273706C6974496E70757422';
wwv_flow_api.g_varchar2_table(80) := '2C2269222C2277616974556E74696C222C22636F6E646974696F6E222C2273657454696D656F7574222C22617272617931222C22617272617932222C22696E7665727465644D617070696E6773222C226D617070696E6773222C2270726F70222C226170';
wwv_flow_api.g_varchar2_table(81) := '706C794D617070696E6773222C22726573756C74222C226B657931222C22637265617465225D2C226D617070696E6773223A223B3B3B3B3B3B3B434151432C53414155412C474143652C6D42414158432C5141417942412C4F41414F432C494145764344';
wwv_flow_api.g_varchar2_table(82) := '2C4F41414F2C434141432C55414157442C4741434D2C6942414158472C5141417542412C4F41414F432C5141453543442C4F41414F432C514141552C53414153432C4541414D432C47416335422C59416265432C49414158442C49414D49412C4541446B';
wwv_flow_api.g_varchar2_table(83) := '422C6F42414158452C4F414345432C514141512C55414752412C514141512C53414152412C4341416B424A2C4941476E434C2C454141514D2C47414344412C474149584E2C454141514D2C5141784268422C45413042452C53414153492C474145502C49';
wwv_flow_api.g_varchar2_table(84) := '414149432C454141572C43414B58432C4941414B2C4B41434C432C614141632C47414364432C614141612C45414362432C65414167422C4741436842432C514141532C47414354432C4F4141512C4341454A432C4D4141532C6942414754432C4D414155';
wwv_flow_api.g_varchar2_table(85) := '2C32424147562C3442414138422C6742414739422C3042414134422C7342414335422C3042414134422C6743414335422C3042414134422C6743414335422C3042414134422C6743414335422C7942414132422C6743414733422C7343414177432C3242';
wwv_flow_api.g_varchar2_table(86) := '414378432C364241412B422C324241472F422C7943414130432C3042414331432C7343414177432C3042414778432C6F43414173432C7942414374432C7143414175432C6744414376432C3443414138432C7742414739432C7743414130432C63414331';
wwv_flow_api.g_varchar2_table(87) := '432C3043414134432C61414335432C3043414134432C6742414335432C3244414136442C7342414337442C3844414167452C6D42414768452C694341416D432C674241436E432C7943414132432C6742414333432C3442414138422C6942414339422C79';
wwv_flow_api.g_varchar2_table(88) := '42414132422C63414733422C694441416B442C674241436C442C6743414169432C714241436A432C2B42414167432C6F4241476843432C554141632C75424145642C2B42414169432C6B4241436A432C2B42414169432C344241436A432C304341413443';
wwv_flow_api.g_varchar2_table(89) := '2C6B42414335432C3043414134432C3842414535432C3842414167432C3242414368432C3042414134422C61414735422C2B42414167432C6B42414368432C6D4341416F432C6B42414370432C6F43414171432C6D42414F7A43432C6B4241416D422C57';
wwv_flow_api.g_varchar2_table(90) := '4143662C4D41414F2C43414748432C6B4241416D422C4741436E42432C6F4241416F422C4541437042432C634141652C4B414766432C65414167422C4741436842432C634141652C47414366432C614141632C47414364432C634141652C47414366432C';
wwv_flow_api.g_varchar2_table(91) := '6B4241416D422C4741436E42432C6B4241416D422C4741436E42432C614141632C47414764432C7742414179422C674241437A42432C574141592C5341435A432C574141592C5341435A432C594141612C55414362432C6742414169422C6341436A4243';
wwv_flow_api.g_varchar2_table(92) := '2C534141552C4F414356432C554141572C51414358432C534141552C4F414356432C574141592C5341435A432C514141532C4D414354432C534141552C4F414356432C574141592C5341435A432C514141532C4D414354432C6D4241416F422C6B434143';
wwv_flow_api.g_varchar2_table(93) := '7042432C6742414169422C6541436A42432C65414167422C6341436842432C6B4241416D422C694241436E42432C6D4241416F422C6B4241437042432C634141652C53414153432C4741414F2C4F41414F412C4741477443432C6742414167422C454143';
wwv_flow_api.g_varchar2_table(94) := '6842432C654141652C45414366432C6742414167422C4541436842432C6742414167422C4541436842432C6D4241416D422C4541436E42432C6742414167422C4541436842432C654141652C45414366432C6B4341416B432C4541436C43432C6B424141';
wwv_flow_api.g_varchar2_table(95) := '6B422C4541436C42432C6F4241416F422C4541437042432C6942414169422C4541436A42432C554141552C45414356432C7942414130422C5341473142432C65414167422C5541436842432C6B4241416D422C5541456E42432C674241416942432C4B41';
wwv_flow_api.g_varchar2_table(96) := '414B78442C494143744279442C7342414173422C4541437442432C614141632C45414364432C6F42414171422C4541437242432C6742414169422C4541436A42432C6B4241416D422C4541456E42432C634141652C43414358432C474141492C4B41434A';
wwv_flow_api.g_varchar2_table(97) := '432C4F4141512C53414352432C514141532C55414354432C534141552C57414356432C514141532C55414354432C594141612C63414362432C4D41414F2C51414350432C514141532C55414354432C534141552C5741435637442C6B4241416D422C7342';
wwv_flow_api.g_varchar2_table(98) := '41436E4238442C4D41414F2C53414350432C65414167422C6D4241436842432C7142414173422C304241437442432C594141612C65414362432C65414167422C6F4241477042432C594141612C53414153432C4541414D432C45414153432C4741415144';
wwv_flow_api.g_varchar2_table(99) := '2C454141512C4B41437244452C594141612C53414153462C45414153432C47414151442C454141512C4B41432F43472C594141612C53414153432C454141614A2C45414153432C47414151442C45414151492C4941433544432C574141592C5341415344';
wwv_flow_api.g_varchar2_table(100) := '2C454141614A2C45414153432C47414151442C45414151492C4941433344452C634141652C53414153462C454141614A2C45414153432C47414151442C4B414374444F2C634141652C53414153482C454141614A2C45414153432C47414151442C454141';
wwv_flow_api.g_varchar2_table(101) := '51492C4941433944492C6F42414171422C534141536E422C454141616F422C474141572C4F41414F412C4541415370422C494143744571422C65414167422C53414153432C4B41437A42432C594141612C53414153432C4B41437442432C514141532C61';
wwv_flow_api.g_varchar2_table(102) := '414354432C634141652C53414153432C4741414F2C4F41414F2C49414149432C4B41414B442C4741414D452C774241513744432C4B41414D2C5341415339462C454141532B462C47414F70422C49414155432C45414E5635432C4B41414B78442C494141';
wwv_flow_api.g_varchar2_table(103) := '4D462C4541414571472C4741436233432C4B41414B78442C4941414971472C534141532C6D4241436C4237432C4B41414B38432C6D4241434C39432C4B41414B2B432C694241474B482C4541416B3944492C55414155432C57414157442C55414155452C';
wwv_flow_api.g_varchar2_table(104) := '5141415139472C4F41414F2B472C4F4141352F446A482C4F41414F6B482C514141516C482C4F41414F6B482C534141532C49414149432C4F41414F2C325441413254432C4B41414B562C494141492C306B444141306B44552C4B41414B562C4541414557';
wwv_flow_api.g_varchar2_table(105) := '2C4F41414F2C454141452C4941436E39446A482C4541414538472C51414151432C5141415172442C4B41414B78442C4941414971472C534141532C554147764337432C4B41414B70442C514141554E2C454141456B482C5141414F2C4541414D2C474141';
wwv_flow_api.g_varchar2_table(106) := '4978442C4B41414B2F432C6F42414171424C2C4741477A446F442C4B41414B70442C514141512B432C554141554B2C4B41414B78442C4941414971472C534141532C614147354337432C4B41414B72442C654141694271442C4B41414B70442C51414151';
wwv_flow_api.g_varchar2_table(107) := '67442C794241476E43492C4B41414B79442C774241474C7A442C4B41414B30442C7342414754582C65414167422C5741435A2F432C4B41414B32442C594141572C4941477042622C694241416B422C5741436439432C4B41414B32442C594141572C4941';
wwv_flow_api.g_varchar2_table(108) := '477042412C574141592C53414153432C4741436A422C49414149432C45414165442C454141532C4D4141512C4B414370432C4941414B2C49414149452C4B41414F39442C4B41414B6E442C4F4141512C4341437A422C494141496B482C45414159442C45';
wwv_flow_api.g_varchar2_table(109) := '414149452C4D41414D2C4B41414B2C4741433342432C45414157482C45414149452C4D41414D2C4B41414B452C4D41414D2C47414147432C4B41414B2C4B41437843432C4541416370452C4B41414B6E442C4F41414F69482C4741414B452C4D41414D2C';
wwv_flow_api.g_varchar2_table(110) := '4B41457A432C494141492C494141494B2C4B414153442C454143622C47414147412C45414159452C65414165442C474141512C4341436C432C49414149452C4541415376452C4B41414B6F452C45414159432C4941473942452C454141536A492C454141';
wwv_flow_api.g_varchar2_table(111) := '456B492C4D41414D442C4541415176452C4D4145542C4941415A69452C454143416A452C4B41414B78442C4941414971482C47414163452C45414157512C4741456C4376452C4B41414B78442C4941414971482C47414163452C45414157452C45414155';
wwv_flow_api.g_varchar2_table(112) := '4D2C4D41576845622C6D4241416F422C57414368422C49414149652C4541414F7A452C4B414558412C4B41414B76442C614141652C474145704275442C4B41414B78442C494141496B492C5141435431452C4B41414B32452C61414B4C33452C4B41414B';
wwv_flow_api.g_varchar2_table(113) := '70442C5141415136452C614141592C534141536D442C47414739422C49414149432C4541416742442C45414163452C4B4141492C53414153432C47414333432C4F41414F4E2C4541414B4F2C6D4241416D42442C4D414B6E434E2C4541414B512C614141';
wwv_flow_api.g_varchar2_table(114) := '614A2C454141652C5541456A4376492C4541414575492C474141654B2C4D41414B2C53414153622C4541414F632C4741436C43562C4541414B572C734241417342442C4D41492F42562C4541414B2F482C614141632C4541476E422B482C4541414B592C';
wwv_flow_api.g_varchar2_table(115) := '61414962432C554141572C574143502C49414149622C4541414F7A452C4B41475075462C4541415576462C4B41414B77462C674241436E4278462C4B41414B78442C49414149694A2C4B41414B2C6D4241416D42432C4F41414F482C474161784376462C';
wwv_flow_api.g_varchar2_table(116) := '4B41414B70442C5141415136452C614158432C534141556F442C474143704276492C4541414575492C474141654B2C4D41414B2C53414153622C4541414F632C4741436C43562C4541414B6B422C63414163522C4D41457642492C454141514B2C594147';
wwv_flow_api.g_varchar2_table(117) := '412C574143524C2C454141514B2C61414D68425A2C6D4241416F422C5341415372442C4741437A422C4941414977442C454141656E462C4B41414B36462C7342414173426C452C47414B39432C4F414A4177442C45414161572C4F4141532C4741437442';
wwv_flow_api.g_varchar2_table(118) := '582C45414161592C65414169422C57414331422C4F41414F5A2C4541416176452C594141596F462C4F4141532C4741457443622C47414758432C7342414175422C53414153442C4741437642412C4541416135452C4D41414D502C4B41414B76442C6541';
wwv_flow_api.g_varchar2_table(119) := '437A4275442C4B41414B76442C6141416130492C4541416135452C4941414D34452C4541476C43412C4541416133452C51414355522C4B41414B69472C6D4241416D42642C4541416133452C514143334373462C4F41414F492C4B41414B662C45414161';
wwv_flow_api.g_varchar2_table(120) := '35452C4D414B724434462C6D4241416F422C5341415368422C4741437A4237492C454141456B482C4F41414F78442C4B41414B76442C6141416130492C4541416135452C4941414B34452C4941476A44452C4F4141512C5741494172462C4B41414B7444';
wwv_flow_api.g_varchar2_table(121) := '2C6341475473442C4B41414B6F472C734241474C70472C4B41414B71472C694241434672472C4B41414B70442C5141415177432C6D4241417142592C4B41414B70442C5141415134432C6B4241416B42512C4B41414B73472C6F4241477A4574472C4B41';
wwv_flow_api.g_varchar2_table(122) := '414B78442C49414149694A2C4B41414B2C63414163472C534145354235462C4B41414B70442C5141415179462C5941476A422B442C6F42414171422C5741436A422C49414349472C454144714276472C4B41414B78442C49414149694A2C4B41414B2C38';
wwv_flow_api.g_varchar2_table(123) := '43414341652C4B41414B2C6B4241437843432C454141637A472C4B41414B78442C49414149694A2C4B41414B2C6F4241417342632C45414167422C4D41437445452C45414159432C534141532C6F4241416F42432C4F41437A43462C45414159472C5141';
wwv_flow_api.g_varchar2_table(124) := '476842502C65414167422C5741435A2C4941414935422C4541414F7A452C4B414758412C4B41414B78442C49414149694A2C4B41414B2C694241416942472C5341432F422C4941414969422C45414163764B2C454141452C514141532C4341437A426945';
wwv_flow_api.g_varchar2_table(125) := '2C474141492C6541434A75472C4D4141532C53414954432C4541416F422C4741437042432C454141552C47414364314B2C4541414530442C4B41414B79422C6541416579442C4D41414B2C53414153622C4541414F632C474143622C4D41417642412C45';
wwv_flow_api.g_varchar2_table(126) := '41416133452C4F41435A75472C4541416B42622C4B41414B662C474145764236422C45414151642C4B41414B662C4D414B72426E462C4B41414B69462C6141416138422C4541416D422F472C4B41414B72442C6742414331434C2C45414145794B2C4741';
wwv_flow_api.g_varchar2_table(127) := '416D4237422C4D41414B2C53414153622C4541414F632C4741437443562C4541414B77432C5741415739422C4541416330422C4D41496C4337472C4B41414B69462C614141612B422C454141532C5541433342314B2C45414145304B2C4741415339422C';
wwv_flow_api.g_varchar2_table(128) := '4D41414B2C53414153622C4541414F632C4741433542562C4541414B77432C5741415739422C4541416330422C4D41496C4337472C4B41414B78442C49414149694A2C4B41414B2C2B4241412B4279422C514141514C2C4941477A44502C6B4241416D42';
wwv_flow_api.g_varchar2_table(129) := '2C574143662C4941414937422C4541414F7A452C4B414758412C4B41414B78442C49414149694A2C4B41414B2C6F4241416F42472C5341436C432C4941414975422C4541416942374B2C454141452C514141532C434143354269452C474141492C6B4241';
wwv_flow_api.g_varchar2_table(130) := '434A75472C4D4141532C534147546C472C454141635A2C4B41414B6F482C69424143764270482C4B41414B69462C6141416172452C454141612C5541432F4274452C4541414573452C4741416173452C4D41414B2C53414153622C4541414F632C474143';
wwv_flow_api.g_varchar2_table(131) := '6843562C4541414B34432C634141636C432C4541416367432C4D414972436E482C4B41414B78442C49414149694A2C4B41414B2C6B4341416B4379422C51414151432C4941473544462C574141592C5341415339422C4541416330422C45414161532C47';
wwv_flow_api.g_varchar2_table(132) := '41433543542C45414163412C4741416537472C4B41414B78442C49414149694A2C4B41414B2C6942414333432C4941414938422C4541415976482C4B41414B77482C71424141714272432C47414731432C47414147412C4541416133452C4F4141512C43';
wwv_flow_api.g_varchar2_table(133) := '414370422C4941414969482C45414169425A2C4541415970422C4B41414B2C7142414171424E2C4541416133452C4F41414F2C4D414333456B482C45414163432C53414153462C45414165472C494141492C694241416D422C47414337445A2C45414155';
wwv_flow_api.g_varchar2_table(134) := '532C4541416568432C4B41414B2C6D4241416D426F432C534141532C634149394437482C4B41414B38482C79424141794233432C4541416133452C51414733432C4941414975482C4541416B424E2C454141654F2C514141512C59414159432C4F414335';
wwv_flow_api.g_varchar2_table(135) := '422C4741413142462C45414167422F422C534141612B422C4541416B424E2C4741456C44462C454141554B2C494141492C6541416742462C454141632C4D41497843562C4541415168422C4F41434967422C4541415169422C4F414356432C4D41414D58';
wwv_flow_api.g_varchar2_table(136) := '2C4741474A452C4541416568432C4B41414B2C6D424143744279422C514141514B2C474149744276482C4B41414B6D492C7342414173424A2C51414B3342522C454141554B2C494141492C65414167422C4F414533424E2C45414343542C454141594B2C';
wwv_flow_api.g_varchar2_table(137) := '514141514B2C4741457042562C454141596E422C4F41414F36422C49414B2F42462C634141652C534141536C432C4541416330422C4741436C43412C45414163412C4741416537472C4B41414B78442C49414149694A2C4B41414B2C6F42414333432C49';
wwv_flow_api.g_varchar2_table(138) := '41414938422C4541415976482C4B41414B77482C71424141714272432C474143314330422C454141594B2C514141514B2C4941477842612C634141652C53414153432C47414370422C4941414935442C4541414F7A452C4B4143506D462C454141656E46';
wwv_flow_api.g_varchar2_table(139) := '2C4B41414B76442C61414161344C2C4741476A43432C454141674274492C4B41414B75492C69424141694270442C4541416135452C49414D76442C47414C416A452C45414145674D2C4741416570442C4D41414B2C53414153622C4541414F6D452C4741';
wwv_flow_api.g_varchar2_table(140) := '436C432F442C4541414B32442C63414163492C454141616A492C4F41496A4334452C4541416133452C4F4141512C43414370422C4941414969492C4541416B427A492C4B41414B69472C6D4241416D42642C4541416133452C51414376446B492C454141';
wwv_flow_api.g_varchar2_table(141) := '6742442C454141674233432C4F41414F36432C5141415178442C4541416135452C49414368456B492C454141674233432C4F41414F38432C4F41414F462C454141652C554149314331492C4B41414B76442C61414161344C2C4741457A422C4941414951';
wwv_flow_api.g_varchar2_table(142) := '2C4541416B4237492C4B41414B78442C49414149694A2C4B41414B2C75424141754234432C454141552C4D41436A45532C45414157442C4541416742622C514141512C63414163432C4F41477244592C45414167426A442C534147684235462C4B41414B';
wwv_flow_api.g_varchar2_table(143) := '6D492C734241417342572C4941472F42432C6F42414171422C53414153432C47414331422C49414149432C4541416B42334D2C45414145304D2C45414147452C654141656C422C514141512C7142414171426D422C5141437044374D2C45414145304D2C';
wwv_flow_api.g_varchar2_table(144) := '45414147452C654141656C422C514141512C654141656D422C5141436A4476442C5341476235462C4B41414B6F4A2C694241416942482C4941473142492C6D4241416F422C53414153432C4541414F4C2C47414368432C4941414978452C4541414F7A45';
wwv_flow_api.g_varchar2_table(145) := '2C4B4145582C47414147734A2C4541414D74442C4F4141512C4341475469442C4941416942412C4541416B426A4A2C4B41414B78442C49414149694A2C4B41414B2C3242414372442C4941414938442C454141654E2C454141674278442C4B41414B2C77';
wwv_flow_api.g_varchar2_table(146) := '42414570432B442C47414457502C4541416742512C534141532C51414362522C454141674278442C4B41414B2C38424147354337452C4541416374452C45414145674E2C4741414F78452C4B4141492C53414153542C4541414F71462C47414333432C4D';
wwv_flow_api.g_varchar2_table(147) := '41414F2C43414348432C55414157442C4541414B452C4B41436842462C4B41414D412C4D414B56472C4541417342374A2C4B41414B384A2C6B4341416B43622C4741436A4572492C45414163412C454141596D4A2C5141414F2C5341415331462C454141';
wwv_flow_api.g_varchar2_table(148) := '4F32462C47414337432C49414149432C474141592C45415368422C4F414E41334E2C45414145754E2C474141714233452C4D41414B2C53414153622C4541414F36462C4741437243462C454141574E2C4B41414B532C4D414151442C4541416D42522C4B';
wwv_flow_api.g_varchar2_table(149) := '41414B532C4D414151482C454141574E2C4B41414B552C4D414151462C4541416D42522C4B41414B552C4F41437647482C474141592C4F41495A412C4B41495468422C4541416742512C534141532C5341437842522C454141674278442C4B41414B2C61';
wwv_flow_api.g_varchar2_table(150) := '41416134452C514141512C5341493943724B2C4B41414B734B2C65414165662C474141632C4741414F2C4741477A43764A2C4B41414B70442C514141516D462C6F4241416F426E422C474141612C53414153324A2C4741456844412C454141714276452C';
wwv_flow_api.g_varchar2_table(151) := '5341477042314A2C45414145694F2C474141734272462C4D41414B2C53414153622C4541414F32462C4741437A432C49414149512C45414167422F462C4541414B67472C324241413242542C474141592C4741436845522C454141714239442C4F41414F';
wwv_flow_api.g_varchar2_table(152) := '38452C4D414968432F462C4541414B32452C694241416942482C494149314278452C4541414B36462C65414165662C474141632C4741414D2C4D414B6844412C4541416139442C4B41414B2C5341415369462C494141492C4B41476E4376432C73424141';
wwv_flow_api.g_varchar2_table(153) := '75422C53414153572C47414535422C47414173432C4D41416C4339492C4B41414B70442C5141415179442C6B4241416A422C434145412C49414149734B2C4541416B4237422C4541415372442C4B41414B2C6D424143684336432C454141674271432C45';
wwv_flow_api.g_varchar2_table(154) := '414167426C462C4B41414B2C594141596D462C494141492C5741437244432C4541416B42462C45414167426C462C4B41414B2C6942414933432C4741484136432C4541416377432C594141592C6D424147612C4941416E43394B2C4B41414B70442C5141';
wwv_flow_api.g_varchar2_table(155) := '415179442C6B424143622C49414149304B2C4541416D427A432C4F41456E4279432C4541416D427A432C4541416370452C4D41414D2C474141496C452C4B41414B70442C5141415179442C6D42415968452C47415241304B2C45414169426C492C534141';
wwv_flow_api.g_varchar2_table(156) := '532C6D424147764267492C454141674270462C4B41414B2C6141416131472C5141415569422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415138422C6B4241436E46714D2C45414169426C492C534141532C5741493342';
wwv_flow_api.g_varchar2_table(157) := '79462C4541416374432C4F41415368472C4B41414B70442C5141415179442C6B4241416D422C43414774442C49414149774B2C454141674237452C4F4141512C434145784236452C4541416B42764F2C454141452C514141532C4341437A42774B2C4D41';
wwv_flow_api.g_varchar2_table(158) := '41532C6D434145622C494141496B452C4541417342314F2C454141452C554141572C4341436E43774B2C4D4141532C534145546D452C45414151334F2C454141452C554141572C4341437242774B2C4D4141532C554149622B442C45414167426E462C4F';
wwv_flow_api.g_varchar2_table(159) := '41414F73462C474141714274462C4F41414F75462C4741436E444E2C45414167427A442C5141415132442C4741493542374B2C4B41414B6B4C2C7542414175424C2C47414169422C5141493743412C45414167426A462C574149784275462C7542414177';
wwv_flow_api.g_varchar2_table(160) := '422C57414370422C4941414931472C4541414F7A452C4B41435036472C4541416337472C4B41414B78442C49414149694A2C4B41414B2C6942414768436F422C4541415970422C4B41414B2C5941415971462C594141592C5741437A436A452C45414159';
wwv_flow_api.g_varchar2_table(161) := '67422C534141532C5941415933432C4D41414B2C53414153622C4541414F31422C4741436C4438422C4541414B30442C734241417342374C2C4541414571472C514149724373432C614141632C534141556D472C45414155432C47414339422C49414149';
wwv_flow_api.g_varchar2_table(162) := '35472C4541414F7A452C4B4147472C63414158714C2C45414343442C45414153452C4D41414B2C53414153432C45414155432C47414337422C49414149432C45414159462C454141537A462C4F41414F452C4F4143354230462C45414159462C45414153';
wwv_flow_api.g_varchar2_table(163) := '31462C4F41414F452C4F414F68432C47414C4776422C4541414B37482C5141415173432C694241435A754D2C47414161462C45414153704B2C5941437442754B2C47414161462C45414153724B2C6141477642754B2C47414161442C4541435A2C4F4141';
wwv_flow_api.g_varchar2_table(164) := '4F432C45414159442C4541496E422C49414149452C454141572C494141496E4A2C4B41414B2B492C45414153394B2C534141536D4C2C55414531432C4F4144652C49414149704A2C4B41414B674A2C454141532F4B2C534141536D4C2C5541437842442C';
wwv_flow_api.g_varchar2_table(165) := '4B414D3142502C45414153452C4D41414B2C53414153432C45414155432C47414337422C49414149472C454141572C494141496E4A2C4B41414B2B492C45414153394B2C534141536D4C2C5541437443432C454141572C49414149724A2C4B41414B674A';
wwv_flow_api.g_varchar2_table(166) := '2C454141532F4B2C534141536D4C2C55414331432C4D4141632C55414158502C454143514D2C45414157452C45414558412C45414157462C4D414D6C43472C7942414130422C53414153542C4741432F422C4941414978452C4541416337472C4B41414B';
wwv_flow_api.g_varchar2_table(167) := '78442C49414149694A2C4B41414B2C69424147354273422C4541416F422F472C4B41414B79422C6341416373492C5141414F2C5341415335452C474141632C4F414151412C4541416133452C5541433946522C4B41414B69462C6141416138422C454141';
wwv_flow_api.g_varchar2_table(168) := '6D4273452C47414772432F4F2C45414145794B2C4741416D4237422C4D41414B2C53414153622C4541414F632C47414374432C494141496F432C45414159562C4541415970422C4B41414B2C7742414177424E2C4541416135452C474141472C4B41437A';
wwv_flow_api.g_varchar2_table(169) := '4573472C454141596E422C4F41414F36422C4F4149334277452C65414167422C5741435A2C49414149432C4541416942684D2C4B41414B78442C49414149694A2C4B41414B2C694341416D437A462C4B41414B72442C65414169422C4D4147354671442C';
wwv_flow_api.g_varchar2_table(170) := '4B41414B78442C49414149694A2C4B41414B2C6B4241416B4271462C594141592C55414335436B422C454141656E4A2C534141532C55414778422C494141496F4A2C454141556A4D2C4B41414B78442C49414149694A2C4B41414B2C7342414335422C47';
wwv_flow_api.g_varchar2_table(171) := '414130422C65414176427A462C4B41414B72442C6541434A73502C45414151704A2C534141532C5541436A426F4A2C4541415178472C4B41414B2C5541415579472C4B41414B462C4541416537432C514141512B432C5941432F432C4341434A2C494141';
wwv_flow_api.g_varchar2_table(172) := '49432C4541416F426E4D2C4B41414B78442C49414149694A2C4B41414B2C3242414132426F432C5741415773422C514143354538432C4541415178472C4B41414B2C5541415579472C4B41414B432C4541416B42442C5141496C446C4D2C4B41414B6F47';
wwv_flow_api.g_varchar2_table(173) := '2C754241475431472C6742414169422C574143624D2C4B41414B78442C4941414971472C534141532C65414D7442754A2C65414167422C5741435A704D2C4B41414B78442C49414149694A2C4B41414B2C614141616B422C5141472F4230462C79424141';
wwv_flow_api.g_varchar2_table(174) := '30422C5341415372442C4741432F422C494143494D2C45414467424E2C4541414773442C63414163432C634143586A442C4D414731422C47414147412C47414179422C4741416842412C4541414D74442C4F4141612C43414733422C4941414969442C45';
wwv_flow_api.g_varchar2_table(175) := '41434175442C45414177426C512C45414145304D2C4541414779442C514141517A452C514141512C7142414171426D422C5141436E4571442C454141734278472C534143724269442C4541416B4275442C4741477442784D2C4B41414B714A2C6D424141';
wwv_flow_api.g_varchar2_table(176) := '6D42432C4541414F4C2C4741432F42442C4541414730442C6D42414958432C634141652C5341415333442C47414570422C47414169422C49414164412C4541414734442C514141652C4341436A422C49414149432C4541415537442C4541414736442C53';
wwv_flow_api.g_varchar2_table(177) := '41415737442C4541414738442C5141432F422C47414147394D2C4B41414B70442C5141415136432C6F42414173426F4E2C4541437A4276512C45414145304D2C45414147452C6541435878432C534141532C6742414167426A422C4B41414B2C53414153';
wwv_flow_api.g_varchar2_table(178) := '34452C514141512C5341436C4472422C454141472B442C6B424143482F442C4541414730442C6D42414B664D2C6F42414171422C5341415368452C47414331422C4941414972472C4541414B72472C45414145304D2C45414147452C6541436476472C45';
wwv_flow_api.g_varchar2_table(179) := '41414736442C4B41414B2C5341415537442C45414147754A2C5341477A42652C384241412B422C534141536A452C47414370432C4941414972472C4541414B72472C45414145304D2C45414147452C65414764354D2C4541414571472C454141472C4741';
wwv_flow_api.g_varchar2_table(180) := '4147754B2C5941415968492C4D41414B2C5741436C426C462C4B41414B6D4E2C55414159432C4B41414B432C57414134422C47414166724E2C4B41414B67472C5141416568472C4B41414B734E2C59414159744E2C4B41414B734E2C674241476846334B';
wwv_flow_api.g_varchar2_table(181) := '2C4541414736442C4B41414B2C5741416137442C45414147754A2C5341437842764A2C4541414736442C4B41414B2C5341415537442C45414147754A2C5141437242764A2C4541414730482C514141512C5941496E426B442C7942414130422C53414153';
wwv_flow_api.g_varchar2_table(182) := '76452C4741432F422C4941434971432C454144652F4F2C45414145304D2C45414147452C6541434731432C4F41414F36452C51414770422C65414158412C45414343724C2C4B41414B73472C6F4241454C74472C4B41414B384C2C794241417942542C47';
wwv_flow_api.g_varchar2_table(183) := '41496C43724C2C4B41414B72442C6541416942304F2C4541437442724C2C4B41414B2B4C2C6B4241475479422C7942414130422C5341415378452C4741452F42412C454141472B442C6B424145597A512C45414145304D2C45414147452C654141657A44';
wwv_flow_api.g_varchar2_table(184) := '2C4B41414B2C6541432F4267492C55414762432C7742414179422C5341415331452C47414339422C4941414932452C4541416572522C45414145304D2C45414147452C654143784279452C454141616A482C534141532C674241416742452C4F41437443';
wwv_flow_api.g_varchar2_table(185) := '2B472C454141616E4E2C5341415369462C4B41414B2C554141556D422C4F414372432B472C454141616E4E2C5341415369462C4B41414B2C7942414179426B422C4F4143704467482C45414161432C5341476A42432C7742414179422C5341415337452C';
wwv_flow_api.g_varchar2_table(186) := '47414339422C4941414938452C4541416378522C45414145304D2C45414147452C6541436E42442C4541416B426A4A2C4B41414B78442C49414149694A2C4B41414B2C3042414368436B492C4541416531452C454141674278442C4B41414B2C61414370';
wwv_flow_api.g_varchar2_table(187) := '4373492C454141694239452C454141674278442C4B41414B2C6742414731437A462C4B41414B674F2C634141634C2C4741476E4231452C454141674278442C4B41414B2C674241416742662C514147724331452C4B41414B6F4A2C694241416942482C47';
wwv_flow_api.g_varchar2_table(188) := '414774426A4A2C4B41414B694F2C7142414171424E2C474141632C4741457843492C4541416570482C4F4143666D482C454141596E482C4F41435A67482C454141616E4E2C5341415369462C4B41414B2C7942414179426D422C4F414370442B472C4541';
wwv_flow_api.g_varchar2_table(189) := '41614F2C5141476A42432C7542414177422C534141536E462C47414337422C494141496F462C4541415739522C45414145304D2C45414147452C65414370426C4A2C4B41414B694F2C714241417142472C474141552C4941477843432C7542414177422C';
wwv_flow_api.g_varchar2_table(190) := '5341415372462C47414337422C494141496F462C4541415739522C45414145304D2C45414147452C65414770422C494141496B462C4541415333492C4B41414B2C6942414169424F2C4F41492F422C47414867426F492C45414153452C4B41414B2C6742';
wwv_flow_api.g_varchar2_table(191) := '414768422C434143562C49414149432C4541416942482C4541415370472C514141512C63414374432C4741414775472C4541416576492C4F4141532C454141472C43414331422C4941414977492C45414157442C4541416574472C4F41414F7A422C4B41';
wwv_flow_api.g_varchar2_table(192) := '414B2C4D4143314334482C45414153452C4B41414B2C63414165452C51414939422C43414343412C454141574A2C4541415370472C514141512C63414163432C4F41414F7A422C4B41414B2C4D4143314434482C45414153452C4B41414B2C6341416545';
wwv_flow_api.g_varchar2_table(193) := '2C47414B72432C4941414976462C4541416B426D462C4541415370472C514141512C7142414171426D422C5141437A4469462C454141532C474141474B2C614141654C2C454141534D2C6341436E437A462C454141674270472C534141532C2B4241457A';
wwv_flow_api.g_varchar2_table(194) := '426F472C454141674236422C594141592C2B4241496843394B2C4B41414B6F4A2C694241416942482C4941473142472C694241416B422C53414153482C47414376422C49414B4930462C45414C41502C454141576E462C454141674278442C4B41414B2C';
wwv_flow_api.g_varchar2_table(195) := '61414368436D4A2C45414161522C4541415331482C534141532C6742414167426A422C4B41414B2C534145704439452C45414155582C4B41414B364F2C6D4241416D42542C474141552C4741433543784E2C454141635A2C4B41414B384A2C6B4341416B';
wwv_flow_api.g_varchar2_table(196) := '43622C4741497A442C4741414739442C614141656E462C4B41414B76442C6141416132522C45414153452C4B41414B2C694241416B422C43414768452C49414349512C45414441432C4541416942704F2C4741415777452C6141416178452C5141453143';
wwv_flow_api.g_varchar2_table(197) := '77452C6141416133452C5341435A734F2C4541416B42334A2C6141416133452C4F41414F774F2C59414931432C49414149432C4541416742622C45414153452C4B41414B2C674241416B42512C4541476844492C47414171422C4541437A422C47414147';
wwv_flow_api.g_varchar2_table(198) := '6C502C4B41414B70442C5141415177432C6B4241416D422C4341432F422C494141492B502C4541417142684B2C6141416176452C594141596B452C4B4141492C534141536B462C474141592C4F41414F412C454141577A4A2C4D41437A46364F2C454141';
wwv_flow_api.g_varchar2_table(199) := '7542784F2C454141596B452C4B4141492C534141536B462C474141592C4F41414F412C454141577A4A2C4D41436C46324F2C47414173426C502C4B41414B71502C65414165462C4541416F42432C4741476C45542C45414155492C4741416B42452C4741';
wwv_flow_api.g_varchar2_table(200) := '416942432C4F41493743502C45414155572C51414151334F2C4541415171462C53414157734A2C51414151314F2C454141596F462C514147374434492C45414157572C594141592C554141575A2C4941477443612C7342414175422C5341415378472C47';
wwv_flow_api.g_varchar2_table(201) := '414335422C4941414938452C4541416378522C45414145304D2C45414147452C6541475234452C4541415970482C534141532C614143784234482C4B41414B2C6942414362522C4541415939462C514141512C634141636D422C5141415132422C594141';
wwv_flow_api.g_varchar2_table(202) := '592C514149704367442C4541415939462C514141512C7142414171426D422C5141432F4376442C55414770426C452C594141612C5341415373482C4741436C422C4941414976452C4541414F7A452C4B41435079502C454141616E542C45414145304D2C';
wwv_flow_api.g_varchar2_table(203) := '45414147452C6541436C42442C4541416B4277472C454141577A482C514141512C7142414171426D422C51414739446E4A2C4B41414B734B2C654141656D462C474141592C4741414F2C47414776432C49414149394E2C4541416333422C4B41414B3050';
wwv_flow_api.g_varchar2_table(204) := '2C6B4241416B427A472C4741477A4374482C4541416333422C4B41414B32502C734241417342684F2C474167427A4333422C4B41414B70442C5141415138452C59414159432C474164582C53414153412C4741436E4238432C4541414B6B422C63414163';
wwv_flow_api.g_varchar2_table(205) := '68452C4741436E4273482C454141674278442C4B41414B2C5541415534452C514141512C534147764335462C4541414B36462C654141656D462C474141592C4741414F2C4D41472F422C57414752684C2C4541414B36462C654141656D462C474141592C';
wwv_flow_api.g_varchar2_table(206) := '4741414D2C4F414D3943394A2C634141652C5341415368452C47414370422C4941414977442C454141656E462C4B41414B67462C6D4241416D4272442C474143334333422C4B41414B6F462C734241417342442C47414733422C4941414930422C454141';
wwv_flow_api.g_varchar2_table(207) := '6337472C4B41414B78442C49414149694A2C4B41414B2C69424143354236422C45414177432C554141764274482C4B41414B72442C654143314271442C4B41414B69482C5741415739422C4541416330422C45414161532C4741456A422C654141764274';
wwv_flow_api.g_varchar2_table(208) := '482C4B41414B72442C674241416D4377492C45414161592C6B42414370442F462C4B41414B71482C634141636C432C494149334276442C574141592C534141536F482C4741436A422C4941414976452C4541414F7A452C4B414350344F2C454141617453';
wwv_flow_api.g_varchar2_table(209) := '2C45414145304D2C45414147452C6541436C42442C4541416B4232462C4541415735472C514141512C7142414171426D422C514143314469462C454141576E462C454141674278442C4B41414B2C61414770437A462C4B41414B734B2C6541416573452C';
wwv_flow_api.g_varchar2_table(210) := '474141592C4741414F2C47414776432C494141496A4E2C4541416572462C454141456B482C4F41414F2C4741414978442C4B41414B76442C6141416132522C45414153452C4B41414B2C6B424143684568532C454141456B482C4F41414F37422C454141';
wwv_flow_api.g_varchar2_table(211) := '612C4341436C426E422C4F414151344E2C45414153452C4B41414B2C674241416B422C4B41437843334E2C51414153582C4B41414B364F2C6D4241416D42542C4741436A43764E2C4D41414F622C4B41414B34502C5341415378422C4741437242314E2C';
wwv_flow_api.g_varchar2_table(212) := '554141552C4941414938422C4D41414F6F4A2C5541437242684C2C594141615A2C4B41414B384A2C6B4341416B43622C4B4149784474482C4541416333422C4B41414B32502C734241417342684F2C474134427A4333422C4B41414B70442C5141415167';
wwv_flow_api.g_varchar2_table(213) := '462C57414157442C47413142562C53414153412C4741496E422C4941414977442C45414165562C4541414B4F2C6D4241416D4272442C554147704377442C45414171422C4F41433542562C4541414B30422C6D4241416D4268422C474147784238442C45';
wwv_flow_api.g_varchar2_table(214) := '4141674278442C4B41414B2C5541415534452C514141512C534147764335462C4541414B6F4C2C674241416742314B2C4541416135452C4941476C436B452C4541414B36462C6541416573452C474141592C4741414F2C4D41472F422C574147526E4B2C';
wwv_flow_api.g_varchar2_table(215) := '4541414B36462C6541416573452C474141592C4741414D2C4F414D39432F4D2C634141652C534141536D482C47414370422C4941414976452C4541414F7A452C4B41435038502C4541416578542C45414145304D2C45414147452C654143704233422C45';
wwv_flow_api.g_varchar2_table(216) := '41415975492C4541416139482C514141512C594141596D422C514143374378482C4541416572462C454141456B482C4F41414F2C4741414978442C4B41414B76442C61414161384B2C454141552B472C4B41414B2C61414337446A472C4541415931472C';
wwv_flow_api.g_varchar2_table(217) := '4541415970422C4741437842694F2C45414157374D2C454141596E422C4F41473342522C4B41414B734B2C6541416577462C474141632C4741414F2C4741477A436E4F2C4541416333422C4B41414B32502C734241417342684F2C474167427A4333422C';
wwv_flow_api.g_varchar2_table(218) := '4B41414B70442C5141415169462C63414163462C474164622C5741435638432C4541414B32442C63414163432C47414368426D472C474141552F4A2C4541414B71442C79424141794230472C47414733432F4A2C4541414B36462C6541416577462C4741';
wwv_flow_api.g_varchar2_table(219) := '41632C4741414F2C4D41476A432C57414752724C2C4541414B36462C6541416577462C474141632C4741414D2C4F414D6844374E2C65414167422C534141532B472C47414372422C494143492B472C4541444B7A542C45414145304D2C45414147452C65';
wwv_flow_api.g_varchar2_table(220) := '4143436F462C4B41414B2C6341437042744F2C4B41414B70442C5141415171462C65414165384E2C4941476843354E2C594141612C5341415336472C4741436C422C494143492B472C4541444B7A542C45414145304D2C45414147452C654143436F462C';
wwv_flow_api.g_varchar2_table(221) := '4B41414B2C6341437042744F2C4B41414B70442C5141415175462C59414159344E2C4941473742432C694241416B422C5341415368482C454141494D2C4741437642412C454141514E2C45414147452C63414163492C4D414137422C494143494C2C4541';
wwv_flow_api.g_varchar2_table(222) := '416B42334D2C45414145304D2C45414147452C654141656C422C514141512C7142414171426D422C51414376456E4A2C4B41414B714A2C6D4241416D42432C4541414F4C2C4941476E436E482C634141652C534141536B482C47414370422C49414D4969';
wwv_flow_api.g_varchar2_table(223) := '482C45414E41784C2C4541414F7A452C4B4145506D462C4541445937492C45414145304D2C45414147452C654141656C422C514141512C634141636D422C514143374233432C4F41414F304A2C4D41476843432C4541417342684C2C4541416168452C59';
wwv_flow_api.g_varchar2_table(224) := '41476E43384F2C45414444394B2C454141612F442C6541434B2B4F2C45414173422C4541457442412C45414173422C4541493343684C2C454141612F442C674241416B422B442C454141612F442C65414335432B442C4541416168452C59414163384F2C';
wwv_flow_api.g_varchar2_table(225) := '45414333426A512C4B41414B6F512C6742414167426A4C2C4541416135452C4941476C432C494141496F422C4541416372462C454141456B482C4F41414F2C4741414932422C4741432F4278442C4541416333422C4B41414B32502C734241417342684F';
wwv_flow_api.g_varchar2_table(226) := '2C474167427A4333422C4B41414B70442C514141516B462C63414163482C474164622C53414153412C4741436E422C4941414977442C45414165562C4541414B4F2C6D4241416D4272442C474143334338432C4541414B30422C6D4241416D4268422C47';
wwv_flow_api.g_varchar2_table(227) := '41437842562C4541414B324C2C6742414167426A4C2C4541416135452C4F414731422C5741475234452C454141612F442C674241416B422B442C454141612F442C65414335432B442C4541416168452C5941416367502C4541433342314C2C4541414B32';
wwv_flow_api.g_varchar2_table(228) := '4C2C6742414167426A4C2C4541416135452C51414D314338502C634141652C5341415372482C47414370422C4941414972472C4541414B72472C45414145304D2C45414147452C6541436476472C454141472B442C534141532C6F4241416F4236492C59';
wwv_flow_api.g_varchar2_table(229) := '4141592C574143354376502C4B41414B6B4C2C75424141754276492C474141492C4941477043324E2C6D4241416F422C5341415374482C4741437A422C4941414975482C454141636A552C45414145304D2C45414147452C6541436E42542C4541416B42';
wwv_flow_api.g_varchar2_table(230) := '38482C4541415976492C514141512C594141596D422C5141415174422C5741415773422C514143724571462C454141572B422C4541415976492C514141512C594141596D422C5141415133432C4F41414F6A472C474147314469512C454141616C552C45';
wwv_flow_api.g_varchar2_table(231) := '4141452C6942414169426D4A2C4B41414B2C7142414B7A432C47414A472B4B2C45414157784B2C51414151774B2C45414157354B2C53414356344B2C454141572F4B2C4B41414B2C6141416136492C4B41414B2C674241476C43452C454141552C434143';
wwv_flow_api.g_varchar2_table(232) := '374267432C4541416178512C4B41414B79512C3642414136426A432C4741432F432F462C454141674268442C4B41414B2C5941415930442C514141516A422C4D41414D73492C4741452F432C4941414970432C454141576F432C454141572F4B2C4B4141';
wwv_flow_api.g_varchar2_table(233) := '4B2C6141432F427A462C4B41414B30512C67424141674274432C4741477242704F2C4B41414B32512C304241413042482C4B41497643492C6B4241416D422C5341415335482C47414378422C494143497A422C454144616A4C2C45414145304D2C454141';
wwv_flow_api.g_varchar2_table(234) := '47452C6541434B6C422C514141512C634141636D422C514143374368452C454141656F432C45414155662C4F41414F304A2C4D4143704333492C4541415531452C534141532C5141476E422C49414149674F2C4541415937512C4B41414B79512C364241';
wwv_flow_api.g_varchar2_table(235) := '413642744C2C4541416133452C4F41415132452C4541416135452C494143704667482C4541415539422C4B41414B2C6F4241416F4230442C514141517A442C4F41414F6D4C2C4741476C442C494141497A432C4541415779432C45414155704C2C4B4141';
wwv_flow_api.g_varchar2_table(236) := '4B2C614143394232492C45414153452C4B41414B2C65414167426E4A2C4541416135452C4941473343364E2C4541415331492C4F41414F31462C4B41414B38512C324241413242334C2C474141632C49414739446E462C4B41414B30512C674241416742';
wwv_flow_api.g_varchar2_table(237) := '74432C4741477242704F2C4B41414B32512C304241413042452C4941476E43452C7142414173422C534141532F482C4741437842684A2C4B41414B70442C5141415177432C6F4241435A592C4B41414B78442C49414149694A2C4B41414B2C7342414173';
wwv_flow_api.g_varchar2_table(238) := '426D432C494141492C4D41414F35482C4B41414B78442C494141492C4741414777552C574143334468522C4B41414B78442C49414149694A2C4B41414B2C7342414173426D422C4F4143704335472C4B41414B78442C4941414971472C534141532C6B42';
wwv_flow_api.g_varchar2_table(239) := '414931426F4F2C6742414169422C534141536A492C47414374422C494141496B492C4541415135552C45414145304D2C45414147452C6541416531432C4B41414B2C63414167422C4541437244304B2C4941434135552C45414145304D2C45414147452C';
wwv_flow_api.g_varchar2_table(240) := '6541416531432C4B41414B2C59414161304B2C474143744335552C45414145304D2C45414147452C6541416572472C534141532C6341476A43734F2C6742414169422C534141536E492C4541414968482C47414331422C494141496B502C454141513555';
wwv_flow_api.g_varchar2_table(241) := '2C45414145304D2C45414147452C6541416531432C4B41414B2C6141437243304B2C4941434135552C45414145304D2C45414147452C6541416531432C4B41414B2C59414161304B2C47414531422C47414154412C4941434335552C45414145304D2C45';
wwv_flow_api.g_varchar2_table(242) := '414147452C6541416534422C594141592C614143374239492C47414155412C4D414972426F502C3042414132422C5341415370492C47414368432C4941414976452C4541414F7A452C4B414358412C4B41414B6D522C6742414167426E492C474141492C';
wwv_flow_api.g_varchar2_table(243) := '574143724276452C4541414B344D2C3242414962432C3442414136422C5341415374492C4741436C43684A2C4B41414B6D522C6742414167426E492C4941477A4275492C7942414130422C5341415376492C4741432F42412C454141472B442C6B424143';
wwv_flow_api.g_varchar2_table(244) := '482F442C4541414730442C694241434831442C4541414773442C634141636B462C61414161432C574141612C5141472F434A2C7142414173422C5741436C4272522C4B41414B78442C49414149694A2C4B41414B2C7342414173426B422C4F4143704333';
wwv_flow_api.g_varchar2_table(245) := '472C4B41414B78442C49414149734F2C594141592C694241477A4234472C574141592C5341415331492C4741436A42412C4541414730442C694241474870512C45414145304D2C4541414779442C5141415170432C514141512C6141477242724B2C4B41';
wwv_flow_api.g_varchar2_table(246) := '414B71522C754241434C72522C4B41414B714A2C6D4241416D424C2C4541414773442C634141636B462C614141616C492C514147314479442C6742414169422C534141532F442C4741437442412C454141472B442C6D42414F5070492C574141592C5741';
wwv_flow_api.g_varchar2_table(247) := '43522C49414749674E2C454141734233522C4B41414B34522C6D4341432F4235522C4B41414B78442C494141496B4A2C4F41414F694D2C4741474B412C4541416F426C4D2C4B41414B2C674241432F426B422C4F414366674C2C4541416F426C4D2C4B41';
wwv_flow_api.g_varchar2_table(248) := '414B2C554141556B422C4F41472F4233472C4B41414B70442C5141415134432C6D42414362512C4B41414B78442C494141496B4A2C4F41414F31462C4B41414B36522C32424143724237522C4B41414B2B4C2C6B424149542C4941414978472C45414155';
wwv_flow_api.g_varchar2_table(249) := '76462C4B41414B77462C674241436E4278462C4B41414B78442C494141496B4A2C4F41414F482C47414768422C49414149754D2C4541416F4278562C454141452C534141552C4341436843774B2C4D4141532C69424143542C694241416B422C61414574';
wwv_flow_api.g_varchar2_table(250) := '4239472C4B41414B78442C494141496B4A2C4F41414F6F4D2C47414768422C49414149432C454141617A562C454141452C534141552C4341437A42774B2C4D4141532C73424143542F482C4B41414D69422C4B41414B70442C514141516B432C63414163';
wwv_flow_api.g_varchar2_table(251) := '6B422C4B41414B70442C514141512B422C6B424145394371542C454141694231562C454141452C4F4141512C4341433342774B2C4D4141532C79424155622C4741524739472C4B41414B70442C51414151632C6B4241416B4273492C5341433942674D2C';
wwv_flow_api.g_varchar2_table(252) := '45414165704B2C494141492C6D4241416F422C5141415135482C4B41414B70442C51414151632C6B4241416B422C4D4143394573552C454141656E502C534141532C55414535426B502C45414157374B2C51414151354B2C454141452C55414155344B2C';
wwv_flow_api.g_varchar2_table(253) := '51414151384B2C4741437643462C4541416B42704D2C4F41414F714D2C47414774422F522C4B41414B70442C5141415177432C6B4241416D422C4341472F422C494141496F4B2C45414175426C4E2C454141452C534141552C4341436E43774B2C4D4141';
wwv_flow_api.g_varchar2_table(254) := '532C69424143542C694241416B422C67424145744239472C4B41414B78442C494141496B4A2C4F41414F38442C47414768422C4941414979492C454141674233562C454141452C534141552C4341433542774B2C4D4141532C79424143542F482C4B4141';
wwv_flow_api.g_varchar2_table(255) := '4D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415167432C71424145394373542C4541416F4235562C454141452C4F4141512C4341433942774B2C4D4141532C304241455639472C4B41414B70442C51414151612C';
wwv_flow_api.g_varchar2_table(256) := '6B4241416B4275492C53414339426B4D2C4541416B42744B2C494141492C6D4241416F422C5141415135482C4B41414B70442C51414151612C6B4241416B422C4D41436A4679552C4541416B4272502C534141532C5541452F426F502C454141632F4B2C';
wwv_flow_api.g_varchar2_table(257) := '51414151354B2C454141452C55414155344B2C51414151674C2C474143314331492C454141714239442C4F41414F754D2C47414935422C49414149452C4541416D4237562C454141452C534141552C4341432F42774B2C4D4141532C7342414754734C2C';
wwv_flow_api.g_varchar2_table(258) := '454141714239562C454141452C534141552C4341436A43774B2C4D4141532C7742414754754C2C454141592F562C454141452C534141552C4341437842774B2C4D4141532C63414754774C2C4541416168572C454141452C4F4141512C4341437642774B';
wwv_flow_api.g_varchar2_table(259) := '2C4D4141532C304241455639472C4B41414B70442C51414151592C6341416377492C5341433142734D2C45414157314B2C494141492C6D4241416F422C5141415135482C4B41414B70442C51414151592C634141632C4D4143744538552C454141577A50';
wwv_flow_api.g_varchar2_table(260) := '2C534141532C55414778422C4941414930502C45414171426A572C454141452C534141552C4341436A4379432C4B41414D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415169432C734241456C4477542C45414155';
wwv_flow_api.g_varchar2_table(261) := '334D2C4F41414F344D2C4741436A42442C45414155334D2C4F41414F364D2C4741456A424A2C45414169426A472C4B41414B6B472C4541416D426C472C4B41414B6D472C49414159314C2C4F4143314433472C4B41414B78442C494141496B4A2C4F4141';
wwv_flow_api.g_varchar2_table(262) := '4F794D2C4B414978424B2C3442414136422C53414153432C4541414B72512C47414376432C4741414771512C454143442C49414149432C454141694270572C454141452C55414155734C2C494141492C4341436A432C6D4241416F422C4F414153364B2C';
wwv_flow_api.g_varchar2_table(263) := '4541414D2C5741476A43432C454141694270572C454141452C4F4141512C4341433342774B2C4D4141532C65414D6A422C4F414841344C2C4541416537502C534141532C6D424143784236502C4541416570452C4B41414B2C65414167426C4D2C474143';
wwv_flow_api.g_varchar2_table(264) := '6A4370432C4B41414B70442C5141415171442C73424141734279532C4541416537502C534141532C534143764436502C47414758642C694341416B432C57414339422C4F41414F35522C4B41414B79512C6B434141364274552C4F414157412C47414157';
wwv_flow_api.g_varchar2_table(265) := '2C4941476E4573552C3642414138422C534141536A432C454141556D452C4541416D42432C47414368452C4941454931562C454143416B462C4541434178422C45414A4136442C4541414F7A452C4B414F50694A2C4541416B42334D2C454141452C5341';
wwv_flow_api.g_varchar2_table(266) := '41552C4341433942774B2C4D4141532C7142414556384C2C47414151334A2C454141674270472C534141532C5141476A4338502C474143437A562C4541416F4238432C4B41414B76442C614141616B572C4741416D427A562C6B4241437A446B462C4541';
wwv_flow_api.g_varchar2_table(267) := '415370432C4B41414B76442C614141616B572C4741416D4237522C5141433943462C454141635A2C4B41414B76442C614141616B572C4741416D422F522C6341496E4431442C4541416F4238432C4B41414B70442C514141514D2C6B4241436A436B462C';
wwv_flow_api.g_varchar2_table(268) := '4541415370432C4B41414B70442C514141516B452C5141437442462C454141632C4941476C422C4941414938522C454141694231532C4B41414B77532C34424141344274562C4541416D426B462C474147724579512C4541416B4276572C454141452C53';
wwv_flow_api.g_varchar2_table(269) := '4141552C4341433942774B2C4D4141532C7142414954674D2C4541416178572C454141452C534141552C4341437A42774B2C4D4141532C674241495473482C4541415739522C454141452C534141552C4341437642774B2C4D4141532C574143542C6D42';
wwv_flow_api.g_varchar2_table(270) := '41416F4239472C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415167422C7942414335446D562C6942414169422C49414972422F532C4B41414B694F2C714241417142472C474141552C47414770432C494141494E2C4541';
wwv_flow_api.g_varchar2_table(271) := '4163394E2C4B41414B67542C6F42414376426C462C454141596A4C2C534141532C6942414772422C494141496F512C4541416B424E2C4541416F422C534141572C4F41436A444F2C4541416942502C4541416F4233532C4B41414B70442C514141516B43';
wwv_flow_api.g_varchar2_table(272) := '2C634141636B422C4B41414B70442C5141415130422C5541415930422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415171422C5541436A4932512C4541416174532C454141452C554141572C4341433142774B2C4D4141';
wwv_flow_api.g_varchar2_table(273) := '536D4D2C4541416B422C3642414333426C552C4B4141516D552C49414D5A2C47414A4174452C4541415770492C4B41414B2C6D4241416F42304D2C47414370434A2C45414157704E2C4F41414F6B4A2C474147662B442C474141714233532C4B41414B6D';
wwv_flow_api.g_varchar2_table(274) := '542C6B4241416B42522C4741416F422C4341472F442C49414149532C4541416D4270542C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415132422C594143334475522C4541416578542C454141452C554141572C43414335';
wwv_flow_api.g_varchar2_table(275) := '42774B2C4D4141532C69424143542F482C4B41414D71552C49414350784C2C494141492C6D4241416F4235482C4B41414B70442C514141516B442C6D424143784367512C45414161744A2C4B41414B2C6D4241416F42344D2C47414374434E2C45414157';
wwv_flow_api.g_varchar2_table(276) := '704E2C4F41414F6F4B2C47414774422C4741414739502C4B41414B70442C5141415177432C6B4241416D422C43414B2F422C494141496D4B2C454141656A4E2C454141452C554141572C4341433542774B2C4D4141532C6D42414554774C2C4541416168';
wwv_flow_api.g_varchar2_table(277) := '572C454141452C4F4141512C4341437642774B2C4D4141532C6F42414554754D2C454141592F572C454141452C574141592C4341433142734E2C4B4141512C4F414352304A2C534141592C5741435A2C594141612C5341476474542C4B41414B70442C51';
wwv_flow_api.g_varchar2_table(278) := '414151592C6341416377492C5341433142734D2C45414157314B2C494141492C6D4241416F422C5141415135482C4B41414B70442C51414151592C634141632C4D4143744538552C454141577A502C534141532C554145784230472C4541416137442C4F';
wwv_flow_api.g_varchar2_table(279) := '41414F344D2C47414159354D2C4F41414F324E2C47414776432C49414149452C4541416D42684B2C45414161694B2C5141437043442C45414169422F4D2C4B41414B2C6D4241416F422B4D2C4541416942314C2C5941433344694C2C45414157704E2C4F';
wwv_flow_api.g_varchar2_table(280) := '41414F364E2C47414766582C47414343432C45414167426E4E2C4F41414F36442C45414161694B2C5141415133512C534141532C6B42414D7A442C4941414932472C45414175426C4E2C454141452C534141552C4341436E43774B2C4D4141532C674241';
wwv_flow_api.g_varchar2_table(281) := '4562784B2C4541414573452C4741416173452C4D41414B2C53414153622C4541414F32462C47414368432C49414149512C45414167422F462C4541414B67472C324241413242542C474141592C4741436845522C454141714239442C4F41414F38452C4D';
wwv_flow_api.g_varchar2_table(282) := '4145684373492C45414157704E2C4F41414F38442C47415374422C47414A41714A2C45414167426E4E2C4F41414F6F492C4741416170492C4F41414F30492C4741415531492C4F41414F6F4E2C4741433544374A2C454141674276442C4F41414F674E2C';
wwv_flow_api.g_varchar2_table(283) := '4741416742684E2C4F41414F6D4E2C474147334372452C454141552C434147544A2C45414153452C4B41414B2C63414165452C47414737422C4941414969462C454141637A542C4B41414B76442C614141612B522C47414370432C4741414769462C4541';
wwv_flow_api.g_varchar2_table(284) := '41596A542C4F4141512C4341436E42344E2C454141536C432C4B41414B2C554147642C4941414977482C454141632C4941414D442C4541415931532C534143684334532C4541416133542C4B41414B34542C694241416942462C454141612C5741415944';
wwv_flow_api.g_varchar2_table(285) := '2C4541415933532C514141532C4341436A462C654141674232532C4541415933532C5541456843734E2C454141536C482C51414151794D2C494169497A422C4F4135484733542C4B41414B70442C5141415130432C674241435A384F2C4541415379462C';
wwv_flow_api.g_varchar2_table(286) := '614141612C434141432C4341436E42432C4D41414F2C6D424143507A502C4D41414F2C4541435030502C4F4141512C534141557A532C4541414D552C4741437042562C4541414F6D442C4541414B75502C67424141674231532C47414F35426D442C4541';
wwv_flow_api.g_varchar2_table(287) := '414B37482C5141415179452C59414159432C4541414D552C47414A6E422C57414352412C454141532C51414B6A4269532C534141552C53414153432C474143662C49414149432C4541415537582C454141452C5541455A38582C4541416D4233502C4541';
wwv_flow_api.g_varchar2_table(288) := '414B2B4E2C34424141344230422C4541414B472C714241457A44432C4541415968592C454141452C534141552C4341437842774B2C4D4141532C59414554794E2C454141536A592C454141452C534141552C4341437242774B2C4D4141532C534143566F';
wwv_flow_api.g_varchar2_table(289) := '462C4B41414B67492C4541414B6E542C5541455479542C454141556C592C454141452C534141552C4341437442774B2C4D4141532C554143566F462C4B41414B67492C4541414B4F2C4F4155622C4F415249502C4541414B4F2C4D41434C482C45414155';
wwv_flow_api.g_varchar2_table(290) := '354F2C4F41414F364F2C47414151374F2C4F41414F384F2C4941456843462C454141557A522C534141532C5941436E4279522C45414155354F2C4F41414F364F2C49414772424A2C454141517A4F2C4F41414F304F2C4741416B42314F2C4F41414F344F';
wwv_flow_api.g_varchar2_table(291) := '2C4741436A43482C454141516A492C5141456E4277492C514141532C53414155522C474149662C4D41414F2C494148477A502C4541414B6D502C6942414169422C4941414D4D2C4541414B6E542C534141552C4F4141516D542C4541414B33542C474141';
wwv_flow_api.g_varchar2_table(292) := '492C4341436C452C654141674232542C4541414B33542C4B4145522C474141476F552C554141592C4F414570432C43414341432C534141552C6D42414356432C6B4241416D422C774241436E42432C534141552C45414356432C6742414169422C454143';
wwv_flow_api.g_varchar2_table(293) := '6A42432C534141552C4D414D6431592C4541414532592C4741414770422C6141416171422C53414153432C5541415539502C4F4141532C534141532B502C4741436E442C49414149432C4541416572562C4B41414B73562C65414165462C4741436E4347';
wwv_flow_api.g_varchar2_table(294) := '2C454141656A5A2C4541414577492C4941414973512C474141592C53414155492C4741414B2C4F41414F412C454141457A462C53414337442C4741414971462C4541415770502C4F4141512C43414372422C4941414979502C454141574C2C454141572C';
wwv_flow_api.g_varchar2_table(295) := '474141474B2C5341437A42412C454141536C562C47414358502C4B41414B78442C4941414938522C4B41414B2C6742414169426D482C454141536C562C4941457843502C4B41414B78442C494141496B5A2C574141572C69424145744231562C4B41414B';
wwv_flow_api.g_varchar2_table(296) := '32562C634141634A2C4741436E4276562C4B41414B34562C634141634C2C47414366462C4941434672562C4B41414B36562C674241416742522C474143724272562C4B41414B38562C6541434C39562C4B41414B2B562C6341434C2F562C4B41414B6757';
wwv_flow_api.g_varchar2_table(297) := '2C774241455068572C4B41414B69572C6B424143496A572C4B41414B6B572C69424143646C572C4B41414B6D572C7742414177425A2C474143704276562C4B41414B6F572C4F41436470572C4B41414B71572C61414F502C49414149432C4541414D334F';
wwv_flow_api.g_varchar2_table(298) := '2C5341415333482C4B41414B78442C494141496F4C2C494141492C514141556E442C4541414B37482C514141516D442C67424141674269522C594143764568522C4B41414B78442C494141496F4C2C494141492C4D41414F304F2C47414770422C494141';
wwv_flow_api.g_varchar2_table(299) := '49432C4541416576572C4B41414B78442C494141496F4C2C494141492C514143684335482C4B41414B78442C494141496F4C2C494141492C4F4141512C47414372422C49414149344F2C454141552F522C4541414B6A492C4941414969612C514141557A';
wwv_flow_api.g_varchar2_table(300) := '572C4B41414B78442C494141496B612C6141437443432C4541414F432C4B41414B432C494141494C2C45414153374F2C53414153344F2C494143744376572C4B41414B78442C494141496F4C2C494141492C4F4141512B4F2C4941517A4272612C454141';
wwv_flow_api.g_varchar2_table(301) := '4532592C4741414770422C6141416169442C67424141674233422C5541415534422C594141632C53414153432C4741432F442C4F414151412C45414157704B2C534143662C4B41414B2C4541434C2C4B41414B2C4741434C2C4B41414B2C4741434C2C4B';
wwv_flow_api.g_varchar2_table(302) := '41414B2C4741454C2C4B41414B2C4741434C2C4B41414B2C4741434C2C4B41414B2C4741434C2C4B41414B2C4741434C2C4B41414B2C474143442C4F41414F2C454145662C474141496F4B2C454141576C4B2C514141532C4F4141516B4B2C4541415770';
wwv_flow_api.g_varchar2_table(303) := '4B2C53414376432C4B41414B2C4741434C2C4B41414B2C474143442C4F41414F2C4B414B684233442C4741475834492C7742414179422C57414372422C494141496F462C4541416533612C454141452C514141532C4341433142774B2C4D4141532C6541';
wwv_flow_api.g_varchar2_table(304) := '45546F512C4541416F4235612C454141452C534141552C4341436843774B2C4D4141532C75424145626D512C4541416176522C4F41414F77522C47414770422C49414149432C4541415337612C454141452C514141532C434143704279432C4B41414D69';
wwv_flow_api.g_varchar2_table(305) := '422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415169422C59414339432C6742414169422C5341436A422C7342414175422C6141497642755A2C4541415339612C454141452C514141532C434143704279432C4B41414D';
wwv_flow_api.g_varchar2_table(306) := '69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C514141516B422C59414339432C6742414169422C5341436A422C7342414175422C6141497642755A2C454141552F612C454141452C514141532C434143724279432C4B4141';
wwv_flow_api.g_varchar2_table(307) := '4D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C514141516D422C61414339432C6742414169422C6141436A422C7342414175422C614149764236432C4541416374452C454141452C514141532C4341437A4279432C4B41';
wwv_flow_api.g_varchar2_table(308) := '414D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C514141516F422C6942414339432C6742414169422C6341436A422C7342414175422C674241497642735A2C4541416B4268622C454141452C4F4141512C434143354277';
wwv_flow_api.g_varchar2_table(309) := '4B2C4D4141532C6F4241455639472C4B41414B70442C51414151612C6B4241416B4275492C534143394273522C454141674231502C494141492C6D4241416F422C5141415135482C4B41414B70442C51414151612C6B4241416B422C4D41432F45365A2C';
wwv_flow_api.g_varchar2_table(310) := '45414167427A552C534141532C55414537426A432C4541415973472C514141516F512C47414970422C49414149432C45414134426A622C454141452C534141552C4341437843774B2C4D4141532C6B4341455430512C45414171426C622C454141452C51';
wwv_flow_api.g_varchar2_table(311) := '4141532C4341436843774B2C4D4141532C6141455432512C45414167426E622C454141452C514141532C4341433342774B2C4D4141532C5541455434512C454141734270622C454141452C6141734235422C4F417042416D622C454141632F522C4F4141';
wwv_flow_api.g_varchar2_table(312) := '4F67532C4741437242482C454141304237522C4F41414F2B522C4741436A43462C454141304237522C4F41414F38522C4741436A43502C4541416176522C4F41414F36522C47414970424C2C4541416B4278522C4F41414F79522C474141517A522C4F41';
wwv_flow_api.g_varchar2_table(313) := '414F30522C4741437843492C4541416D4239522C4F41414F79522C4541414F33442C53414153394E2C4F41414F30522C4541414F35442C554145724478542C4B41414B70442C514141516F432C674241416B4267422C4B41414B70442C5141415173432C';
wwv_flow_api.g_varchar2_table(314) := '6B424143334367592C4541416B4278522C4F41414F32522C4741437A42472C4541416D4239522C4F41414F32522C4541415137442C5541456E4378542C4B41414B70442C5141415177432C6F4241435A38582C4541416B4278522C4F41414F39452C4741';
wwv_flow_api.g_varchar2_table(315) := '437A4232572C454141304237522C4F41414F39452C4541415934532C554147394378542C4B41414B70442C5141415138432C6942414169424D2C4B41414B4E2C6B4241432F4275582C474147587A522C634141652C534141536D532C47414370422C4941';
wwv_flow_api.g_varchar2_table(316) := '414970532C454141556A4A2C454141452C534141552C4341437442774B2C4D4141532C5941455636512C4741415170532C4541415131432C534141532C55414535422C494141492B552C4541416374622C454141452C4F4141512C4341437842774B2C4D';
wwv_flow_api.g_varchar2_table(317) := '4141532C3042414F622C4F414C4739472C4B41414B70442C51414151532C6541416532492C534143334234522C4541415968512C494141492C6D4241416F422C5141415135482C4B41414B70442C51414151532C654141652C4D4143784575612C454141';
wwv_flow_api.g_varchar2_table(318) := '592F552C534141532C5541457A4230432C4541415132472C4B41414B304C2C4741434E72532C47414758794E2C6B4241416D422C5341415336452C47414378422C494141492F4A2C4541416378522C454141452C554141572C4341433342774B2C4D4141';
wwv_flow_api.g_varchar2_table(319) := '532B512C474141612C5541477442432C4541414F78622C454141452C4F4141512C4341436A42774B2C4D4141532C67424153622C4F41504739472C4B41414B70442C51414151652C6141416171492C5341437A4238522C4541414B6C512C494141492C6D';
wwv_flow_api.g_varchar2_table(320) := '4241416F422C5141415135482C4B41414B70442C51414151652C614141612C4D41432F446D612C4541414B6A562C534141532C5541476C42694C2C4541415935422C4B41414B344C2C47414556684B2C4741475874472C7142414173422C534141537243';
wwv_flow_api.g_varchar2_table(321) := '2C47414733422C494141496F432C454141596A4C2C454141452C514141532C43414376422C5541415736492C4541416135452C474143784275472C4D4141532C594143564E2C4B41414B2C5141415372422C47414564412C454141616A452C7342414173';
wwv_flow_api.g_varchar2_table(322) := '4271472C4541415531452C534141532C6D424143744473432C454141616C452C67424141674273472C4541415531452C534141532C5941476E442C4941414979462C4541416742684D2C454141452C514141532C4341433342774B2C4D4141532C6D4241';
wwv_flow_api.g_varchar2_table(323) := '495469522C45414169422F582C4B41414B67592C34424141344237532C47414974442C4F4146416F432C4541415537422C4F41414F71532C4741436D4278512C4541415537422C4F41414F34432C4741433943662C4741475879512C3442414136422C53';
wwv_flow_api.g_varchar2_table(324) := '41415337532C4741436C432C49414149562C4541414F7A452C4B4145502B582C45414169427A622C454141452C534141552C4341433742774B2C4D4141532C6F42414954344C2C454141694231532C4B41414B77532C344241413442724E2C454141616A';
wwv_flow_api.g_varchar2_table(325) := '492C6B4241416D4269492C4541416172452C5341472F4679422C4541414F6A472C454141452C554141572C434143704279432C4B41414D69422C4B41414B70442C5141415130462C6341416336432C4541416131452C53414339432C6742414169423045';
wwv_flow_api.g_varchar2_table(326) := '2C4541416131452C554149394277582C4541416B4233622C454141452C534141552C4341433942774B2C4D4141532C6D42414954794E2C454141536A592C454141452C554141572C4341437442774B2C4D4141532C4F4143542C654141674233422C4541';
wwv_flow_api.g_varchar2_table(327) := '416172452C51414337422F422C4B4141516F472C454141616A452C7142414175426C422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415179422C5341415738472C4541416170452C57415368482C474150416B582C4541';
wwv_flow_api.g_varchar2_table(328) := '41674276532C4F41414F364F2C474149704270502C454141616C452C67424141674273542C4541414F31522C534141532C75424147374373432C4541416133452C4F4141512C43414370422C49414149412C45414153522C4B41414B76442C6141416130';
wwv_flow_api.g_varchar2_table(329) := '492C4541416133452C51414335432C47414147412C4541414F412C4F4141512C434143642C4941414930582C4541415535622C454141452C554141572C4341437642774B2C4D4141532C574143542F482C4B41415179422C4541414F4F2C534143662C65';
wwv_flow_api.g_varchar2_table(330) := '41416742502C4541414F4D2C554149764271582C4541415937622C454141452C4F4141512C4341437442774B2C4D4141532C674241455639472C4B41414B70442C51414151572C6141416179492C5341437A426D532C4541415576512C494141492C6D42';
wwv_flow_api.g_varchar2_table(331) := '41416F422C5141415135482C4B41414B70442C51414151572C614141612C4D4143704534612C4541415574562C534141532C554147764271562C4541415168522C5141415169522C4741436842462C454141674276532C4F41414F77532C49414B2F422C';
wwv_flow_api.g_varchar2_table(332) := '474141472F532C454141616E452C4D41414F2C4341436E422C494141496F582C4541415339622C454141452C554141572C4341437442774B2C4D4141532C32424143542F482C4B41414D69422C4B41414B70442C514141516B432C634141636B422C4B41';
wwv_flow_api.g_varchar2_table(333) := '414B70442C5141415134422C5741456C44795A2C454141674276532C4F41414F30532C47414933422C494141496A452C4541415537582C454141452C534141552C4341437442774B2C4D4141532C59414D546E472C4541415572452C454141452C534141';
wwv_flow_api.g_varchar2_table(334) := '552C4341437442774B2C4D4141532C59414B622C474148416E472C45414151754C2C4B41414B6C4D2C4B41414B38512C324241413242334C2C4941473143412C454141617A452C5541415979452C454141617A452C5541415979452C4541416131452C51';
wwv_flow_api.g_varchar2_table(335) := '4141532C43414376452C4941414934582C4541416172592C4B41414B70442C5141415130462C6341416336432C454141617A452C554143724434582C4541415368632C454141452C554141572C4341437442774B2C4D4141532C534143542F482C4B4141';
wwv_flow_api.g_varchar2_table(336) := '4D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415177422C594141632C4941414D69612C4541436C452C6742414169426C542C454141617A452C5741456C43432C454141512B452C4F41414F34532C47414F6E422C';
wwv_flow_api.g_varchar2_table(337) := '4941414931582C4541416374452C454141452C534141552C4341433142774B2C4D4141532C674241455479522C45414171426A632C454141452C534141552C4341436A43774B2C4D4141532C6141455430522C45414169426C632C454141452C53414155';
wwv_flow_api.g_varchar2_table(338) := '2C4341433742774B2C4D4141532C534145626C472C4541415938452C4F41414F36532C4741416F4237532C4F41414F38532C474145334378592C4B41414B70442C5141415177432C6D42414171422B462C45414161592C6B42414339437A4A2C45414145';
wwv_flow_api.g_varchar2_table(339) := '36492C4541416176452C6141416173452C4D41414B2C53414153622C4541414F32462C47414337432C494143494A2C4F41414F7A4E2C454147582C47414147364E2C454141574C2C554141572C43414372422C49414149384F2C45414167427A4F2C4541';
wwv_flow_api.g_varchar2_table(340) := '41574C2C5541415533462C4D41414D2C4B414370422C474141784279552C454141637A532C5341434A79532C454141632C4741437642374F2C4541414F364F2C454141632C49414B37422C474141572C53414152374F2C47414132422C53414152412C45';
wwv_flow_api.g_varchar2_table(341) := '414169422C4341436E432C49414149384F2C4541416170632C454141452C5541476671632C4541415572632C454141452C4F4141512C4341437042774B2C4D4141532C5541435438522C4B41414D354F2C454141574E2C4B41436A422B432C4F4141512C';
wwv_flow_api.g_varchar2_table(342) := '57414B5A2C47414841694D2C45414157784D2C4B41414B794D2C4741474C2C534141522F4F2C45414169422C43414368422C4941414969502C4541415176632C454141452C534141552C43414370426D572C4941414B7A492C454141574E2C4F41457042';
wwv_flow_api.g_varchar2_table(343) := '69502C454141517A4D2C4B41414B324D2C4F4147562C434143482C49414149432C4541415178632C454141452C574141592C43414374426D572C4941414B7A492C454141574E2C4B41436842452C4B41414D492C454141574C2C5541436A426F502C5341';
wwv_flow_api.g_varchar2_table(344) := '41552C614145644A2C454141517A4D2C4B41414B344D2C4741456A42502C4541416D4237532C4F41414F67542C47414939422C494141496C4F2C45414167422F462C4541414B67472C324241413242542C474141592C4741436845774F2C454141653953';
wwv_flow_api.g_varchar2_table(345) := '2C4F41414F38452C4D415139422C49414149774F2C4541415531632C454141452C554141572C4341437642774B2C4D4141532C594149546D532C4541415933632C454141452C554141572C4341437A42774B2C4D4141532C594143542F482C4B41414D2C';
wwv_flow_api.g_varchar2_table(346) := '4D41494E6D612C4541415135632C454141452C594141612C4341437642774B2C4D4141532C6541435438432C4B4141512C53414352374B2C4B41414D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415173422C6141';
wwv_flow_api.g_varchar2_table(347) := '49394369622C4541416137632C454141452C4F4141512C4341437642774B2C4D4141532C6F4241455639472C4B41414B70442C51414151552C6341416330492C53414331426D542C4541415776522C494141492C6D4241416F422C5141415135482C4B41';
wwv_flow_api.g_varchar2_table(348) := '414B70442C51414151552C634141632C4D4143744536622C4541415774572C534141532C55414978422C4941414975572C45414155705A2C4B41414B715A2C6F4241416F426C552C47414D76432C474148476E462C4B41414B70442C514141516F432C67';
wwv_flow_api.g_varchar2_table(349) := '424141674267612C4541415174542C4F41414F77542C47414335436C5A2C4B41414B70442C5141415173432C674241416742385A2C4541415174542C4F41414F30542C47414535436A552C454141616A452C7342414177426C422C4B41414B70442C5141';
wwv_flow_api.g_varchar2_table(350) := '41514F2C6D4241416F422C43414372452C494141496D632C4541416168642C454141452C594141612C4341433542774B2C4D4141532C634143542F482C4B41414D69422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C51414151';
wwv_flow_api.g_varchar2_table(351) := '75422C5941456C4436612C4541415174542C4F41414F34542C4741636E422C4F4156414E2C454141516E522C5741415733432C4D41414B2C53414153622C4541414F6B562C47414368436A642C4541414569642C47414155432C474141472C6742414366';
wwv_flow_api.g_varchar2_table(352) := '6C642C4541414569642C4741415572522C4D41414D2B512C454141557A462C5941497043572C454141517A4F2C4F41414F2F452C4741436677542C454141517A4F2C4F41414F39452C4741436675542C454141517A4F2C4F41414F73542C474143666A42';
wwv_flow_api.g_varchar2_table(353) := '2C4541416572532C4F41414F674E2C4741416742684E2C4F41414F6E442C4741414D6D442C4F41414F75532C474141694276532C4F41414F794F2C474143334534442C4741475873422C6F42414171422C534141536C552C47414531422C494141496755';
wwv_flow_api.g_varchar2_table(354) := '2C4541416137632C454141452C4F4141512C4341437642774B2C4D4141532C6F424165622C4F41624739472C4B41414B70442C51414151552C6341416330492C53414331426D542C4541415776522C494141492C6D4241416F422C5141415135482C4B41';
wwv_flow_api.g_varchar2_table(355) := '414B70442C51414151552C634141632C4D4143744536622C4541415774572C534141532C5541495476472C454141452C594141612C4341433142774B2C4D4141532C694241416D4233422C454141612F442C65414169422C6B4241416F422C4D41432F45';
wwv_flow_api.g_varchar2_table(356) := '73452C4F41414F704A2C454141452C554141572C4341436E4279432C4B41414D6F472C4541416168452C5941436E4232462C4D4141532C6B4241435470422C4F41414F79542C49414B6676462C694241416B422C5341415337552C4541414D30612C4541';
wwv_flow_api.g_varchar2_table(357) := '4163314A2C4541414F324A2C4741436C442C49414149432C4541415172642C454141452C574141592C4341437442774B2C4D4141532C4D41435438432C4B4141512C534143522C594141612C53414D6A422C4F414A4736502C47414163452C4541414D39';
wwv_flow_api.g_varchar2_table(358) := '572C5341415334572C4741436843452C4541414D6A502C49414149334C2C4741435634612C4541414D724C2C4B41414B2C6141416379422C4741437242324A2C4741416942432C4541414D724C2C4B41414B6F4C2C4741437A42432C474147586C502C32';
wwv_flow_api.g_varchar2_table(359) := '42414134422C53414153542C4541415934502C47414737432C4941414970502C45414167426C4F2C454141452C4F4141512C4341433142774B2C4D4141532C694241435432462C4F4141552C574149566D4E2C4741434170502C4541416338442C4B4141';
wwv_flow_api.g_varchar2_table(360) := '4B2C4F41415174452C454141574E2C4D41493143632C4541416368452C4B41414B2C434143666A472C47414149794A2C454141577A4A2C474143666F4A2C554141574B2C454141574C2C5541437442442C4B41414D4D2C454141574E2C4F414972422C49';
wwv_flow_api.g_varchar2_table(361) := '4141496D512C454141572C474147662C4741414737502C454141574E2C6742414167426F512C4B41433142442C4541415737502C454141574E2C4B41414B532C53414778422C434143482C4941414934502C454141512F502C454141574E2C4B41414B31';
wwv_flow_api.g_varchar2_table(362) := '462C4D41414D2C4B41456C4336562C47414449412C45414157452C4541414D412C4541414D2F542C4F4141532C494143684268432C4D41414D2C4B41414B2C4741432F4236562C45414157472C6D4241416D42482C4741496C432C49414149492C454141';
wwv_flow_api.g_varchar2_table(363) := '694233642C454141452C4F4141512C4341433342774B2C4D4141532C6F424157622C4741544739472C4B41414B70442C51414151612C6B4241416B4275492C534143394269552C4541416572532C494141492C6D4241416F422C5141415135482C4B4141';
wwv_flow_api.g_varchar2_table(364) := '4B70442C51414151612C6B4241416B422C4D4143394577632C4541416570582C534141532C554149354232482C4541416339452C4F41414F75552C45414167424A2C4741476C43442C454141572C4341435670502C4541416333482C534141532C614147';
wwv_flow_api.g_varchar2_table(365) := '76422C49414149694C2C45414163394E2C4B41414B67542C6B4241416B422C5541437A4378492C4541416339452C4F41414F6F492C4741477A422C4F41414F74442C4741475871462C6742414169422C5341415374502C47414374422C4941414934452C';
wwv_flow_api.g_varchar2_table(366) := '454141656E462C4B41414B76442C6141416138442C4741436A4373492C4541416B4237492C4B41414B78442C49414149694A2C4B41414B2C7542414175424E2C4541416135452C474141472C4D414576456B452C4541414F7A452C4B41435836492C4541';
wwv_flow_api.g_varchar2_table(367) := '41674233442C4D41414B2C53414153622C4541414F6B442C4741436A432C4941414977512C454141694274542C4541414B75542C34424141344237532C474143744437492C45414145694C2C4741415739422C4B41414B2C6F4241416F4230442C514141';
wwv_flow_api.g_varchar2_table(368) := '512B512C594141596E432C4F41496C456A512C7942414130422C5341415376482C4741432F422C4941414934452C454141656E462C4B41414B76442C6141416138442C4741436A4373492C4541416B4237492C4B41414B78442C49414149694A2C4B4141';
wwv_flow_api.g_varchar2_table(369) := '4B2C7542414175424E2C4541416135452C474141472C4D414576456B452C4541414F7A452C4B41435836492C454141674233442C4D41414B2C53414153622C4541414F6B442C4741436A432C4941414977512C454141694274542C4541414B75542C3442';
wwv_flow_api.g_varchar2_table(370) := '4141344237532C474143744437492C45414145694C2C4741415739422C4B41414B2C5941415930442C514141512B512C594141596E432C4541416574532C4B41414B2C694241493945324B2C6742414169422C5341415337502C47414374422C49414149';
wwv_flow_api.g_varchar2_table(371) := '34452C454141656E462C4B41414B76442C6141416138442C4741436A4373492C4541416B4237492C4B41414B78442C49414149694A2C4B41414B2C7542414175424E2C4541416135452C474141472C4D414576456B452C4541414F7A452C4B4143583649';
wwv_flow_api.g_varchar2_table(372) := '2C454141674233442C4D41414B2C53414153622C4541414F6B442C4741436A432C4941414936522C4541415533552C4541414B34552C6F4241416F426C552C474143764337492C45414145694C2C4741415739422C4B41414B2C5741415730442C514141';
wwv_flow_api.g_varchar2_table(373) := '512B512C59414159642C4F41517A4433562C7342414175422C5741476E426E482C454141452C6B4341416B43734A2C534147704335462C4B41414B6D612C554141552C2B444143546E612C4B41414B70442C5141415169442C6541416B422C6541436A43';
wwv_flow_api.g_varchar2_table(374) := '2C4B41474A472C4B41414B6D612C554141552C71454143546E612C4B41414B70442C5141415169442C6541416B422C6541436A432C4B41474A472C4B41414B6D612C554141552C75444143546E612C4B41414B70442C5141415169442C6541416B422C65';
wwv_flow_api.g_varchar2_table(375) := '41436A432C4B41474A472C4B41414B6D612C554141552C34434143546E612C4B41414B70442C5141415169442C6541444A2C6942414766472C4B41414B6D612C554141552C69444143546E612C4B41414B70442C5141415169442C6541444A2C6F43414D';
wwv_flow_api.g_varchar2_table(376) := '6E4273612C554141572C5341415376532C47414368422C4941414977532C4541415539642C454141452C574141592C4341437842734E2C4B41414D2C5741434E39432C4D4141532C73424143542F482C4B41414D36492C49414556744C2C454141452C51';
wwv_flow_api.g_varchar2_table(377) := '4141516F4A2C4F41414F30552C49414F724233592C594141612C574143542C4941414967442C4541414F7A452C4B4143582C4F41414F71612C4F41414F432C4B41414B74612C4B41414B76442C6341416371492C4B4141492C5341415376452C47414149';
wwv_flow_api.g_varchar2_table(378) := '2C4F41414F6B452C4541414B68492C6141416138442C4F4147704667492C694241416B422C5341415369472C47414376422C4F41414F784F2C4B41414B79422C6341416373492C5141414F2C5341415377512C474141532C4F41414F412C454141512F5A';
wwv_flow_api.g_varchar2_table(379) := '2C51414155674F2C4D4147684670482C65414167422C5741435A2C4F41414F70482C4B41414B79422C6341416373492C5141414F2C5341415377512C474141532C4F41414F412C4541415178552C714241477445452C6D4241416F422C5341415375552C';
wwv_flow_api.g_varchar2_table(380) := '4741437A422C49414149684D2C45414157674D2C454143662C454141472C434143432C49414149432C45414167427A612C4B41414B76442C614141612B522C4741437443412C45414157694D2C454141636A612C614143472C4D4141784269612C454141';
wwv_flow_api.g_varchar2_table(381) := '636A612C51414374422C4F41414F69612C474147582F4B2C6B4241416D422C534141537A472C47414378422C494141496D462C454141576E462C454141674278442C4B41414B2C61414368436C442C4741414F2C49414149432C4D41414F6B592C634167';
wwv_flow_api.g_varchar2_table(382) := '4274422C4D41646B422C434143646E612C474141492C4B414151502C4B41414B79422C6341416375452C4F4141532C474143784378462C4F414151344E2C45414153452C4B41414B2C674241416B422C4B41437843374E2C5141415338422C4541435437';
wwv_flow_api.g_varchar2_table(383) := '422C5341415536422C4541435635422C51414153582C4B41414B364F2C6D4241416D42542C4741436A43764E2C4D41414F622C4B41414B34502C5341415378422C4741437242724E2C53414155662C4B41414B70442C514141516B432C634141636B422C';
wwv_flow_api.g_varchar2_table(384) := '4B41414B70442C5141415179422C5341436C446E422C6B4241416D4238432C4B41414B70442C514141514D2C6B424143684367452C7342414173422C4541437442432C594141612C45414362432C6742414167422C4541436842522C594141615A2C4B41';
wwv_flow_api.g_varchar2_table(385) := '414B384A2C6B4341416B43622C4B414B35446B4B2C6B4241416D422C53414153394B2C47414378422C4741414772492C4B41414B70442C5141415175432C65414167422C43414335422C4941414967552C4741416F422C45414D78422C4F414C496E542C';
wwv_flow_api.g_varchar2_table(386) := '4B41414B70442C5141415132432C6B434143626A442C4541414530442C4B41414B79422C6541416579442C4D41414B2C53414153622C4541414F6B572C4741437043412C454141512F5A2C5141415536482C49414157384B2C4741416F422C4D41477244';
wwv_flow_api.g_varchar2_table(387) := '412C454145582C4F41414F2C474147586A492C7542414177422C534141534C2C454141694234432C47414339432C49414149684A2C4541414F7A452C4B41435032612C454141674239502C454141674270462C4B41414B2C614143724377462C45414151';
wwv_flow_api.g_varchar2_table(388) := '4A2C454141674270462C4B41414B2C55414537426D562C4541416F422C57414370422C4941414937622C4541414F30462C4541414B37482C514141516B432C6341416332462C4541414B37482C5141415136422C6F4241432F436F632C4541416168512C';
wwv_flow_api.g_varchar2_table(389) := '45414167426E452C534141532C594141596B452C494141492C5741415735452C4F414372456A482C4541414F412C4541414B32562C514141512C694241416B426D472C4741437443462C4541416335622C4B41414B412C4941476E424C2C4541416B4273';
wwv_flow_api.g_varchar2_table(390) := '422C4B41414B70442C514141516B432C634141636B422C4B41414B70442C5141415138422C6942414533442B4F2C474147496B4E2C4541416335622C514141554C2C45414376426B632C49414541442C4541416335622C4B41414B4C2C4741477642754D';
wwv_flow_api.g_varchar2_table(391) := '2C4541414D73452C594141592C4F414B666F4C2C4541416335622C514141554C2C47414376426B632C4B414B5A74512C65414167422C5341415377512C454141516E4D2C454141536F4D2C4741437443442C4541414F764C2C594141592C554141575A2C';
wwv_flow_api.g_varchar2_table(392) := '47414333426F4D2C45414343442C4541414F354F2C4B41414B6C4D2C4B41414B77462C654141632C4941452F4273562C4541414F354F2C4B41414B344F2C4541414F74552C4B41414B2C73424149684379482C7142414173422C53414153472C45414155';
wwv_flow_api.g_varchar2_table(393) := '522C4741537243512C4541415739522C4541414538522C474143622C49414C51344D2C45414B4A432C4541416F422C47414154724E2C4541416742354E2C4B41414B70442C5141415175442C6F4241417342482C4B41414B70442C5141415173442C6141';
wwv_flow_api.g_varchar2_table(394) := '432F452C454141472C43414E4B38612C4F414141412C45414141412C45414A69422C494143522C4D41554C432C4541506B432C4741433143374D2C4541415378472C494141492C534141556F542C454141532C4D414F6843432C494143412C4941414943';
wwv_flow_api.g_varchar2_table(395) := '2C4541416D42394D2C454141532C474141474B2C614141654C2C454141534D2C6341437644794D2C45414138432C47414168436E622C4B41414B70442C5141415177442C694241436E4236612C454141576A622C4B41414B70442C5141415177442C7342';
wwv_flow_api.g_varchar2_table(396) := '4143684338612C4941417142432C4941476A436E4E2C634141652C53414153492C4741437042412C45414153314A2C5141415132462C514141512C554147374277452C6D4241416F422C53414153542C45414155674E2C4741436E432C49414149432C45';
wwv_flow_api.g_varchar2_table(397) := '414167426A4E2C454141536F462C514147374236482C4541416335562C4B41414B2C694241416942472C534147704379562C4541416335562C4B41414B2C67424141674279552C614141592C57414333432C4F41414F6B422C454141674239652C454141';
wwv_flow_api.g_varchar2_table(398) := '4530442C4D41414D304B2C4D4141512C4941414D704F2C4541414530442C4D41414D734F2C4B41414B2C6942414539442B4D2C4541416335562C4B41414B2C6141416179552C614141592C57414378432C4F41414F6B422C454141674239652C45414145';
wwv_flow_api.g_varchar2_table(399) := '30442C4D41414D304B2C4D4141512C4941414D704F2C4541414530442C4D41414D734F2C4B41414B2C6942414739442C49414149674E2C4541414B68662C454141452C5541415534502C4B41414B6D502C454141636E502C51414378436F502C45414147';
wwv_flow_api.g_varchar2_table(400) := '37562C4B41414B2C6341416379552C614141592C574141612C4D41414F2C4B41414F6C612C4B41414B75622C6141476C452C4941414978632C4541414F75632C4541414776632C4F41414F32562C514141512C514141532C49414974432C4F4144493356';
wwv_flow_api.g_varchar2_table(401) := '2C4541414F69422C4B41414B67552C6742414167426A562C49414970432B522C3242414134422C53414153334C2C4541416371572C4741432F432C4941414974502C4541414F6C4D2C4B41414B79622C4F41414F74572C4541416178452C53414970432C';
wwv_flow_api.g_varchar2_table(402) := '4F414841754C2C4541414F6C4D2C4B41414B30622C5141415178502C4741437042412C4541414F6C4D2C4B41414B32622C6341416378572C454141632B472C474143724373502C494141694274502C4541414F412C4541414B77492C514141512C554141';
wwv_flow_api.g_varchar2_table(403) := '572C534143354378492C4741535830442C534141552C5341415378422C474143662C49414149764E2C454141512C47414D5A2C4F414C41754E2C4541415333492C4B41414B2C53414153502C4D41414B2C53414153622C4541414F31422C47414378432C';
wwv_flow_api.g_varchar2_table(404) := '4941414970432C4541414B6F482C53414153724C2C4541414571472C47414149324C2C4B41414B2C6541437A4279422C454141517A542C4541414571472C474141492B482C4D41436C42374A2C4541414D4E2C4741414D77502C4541414D374C2C4D4141';
wwv_flow_api.g_varchar2_table(405) := '4D2C4D4145724272442C47414758694A2C6B4341416D432C53414153622C47414B78432C4F414A6B42412C454141674278442C4B41414B2C344241413442582C4B4141492C5741436E452C4F41414F78492C4541414530442C4D41414D77472C55414368';
wwv_flow_api.g_varchar2_table(406) := '426F562C57414B506C4C2C6742414169422C534141532F4E2C47415574422C47415441412C4541414B72472C4541414571472C474141492C4741475872472C4541414571472C4741414930482C514141512C534147642F4E2C4541414571472C47414149';
wwv_flow_api.g_varchar2_table(407) := '714F2C55414155724F2C45414147384C2C6D424147652C494141764272532C4F41414F79662C6D42414138442C4941417842432C53414153432C59414134422C4341437A462C49414149432C45414151462C53414153432C6341437242432C4541414D43';
wwv_flow_api.g_varchar2_table(408) := '2C6D4241416D42745A2C4741437A42715A2C4541414D452C554141532C474143662C49414149432C4541414D2F662C4F41414F79662C6541436A424D2C45414149432C6B4241434A442C45414149452C534141534C2C514143562C51414134432C494141';
wwv_flow_api.g_varchar2_table(409) := '6A43462C53414153512C4B41414B432C6742414167432C43414335442C49414149432C45414159562C53414153512C4B41414B432C6B4241433942432C45414155432C6B4241416B42395A2C4741433542365A2C454141554E2C554141532C4741436E42';
wwv_flow_api.g_varchar2_table(410) := '4D2C45414155452C534149642F5A2C45414147694C2C534147502B432C3042414132422C53414153684F2C47414368432C4941414967612C4541416568612C4541414769612C5741415774472C494143374275472C454141656C612C4541414769612C57';
wwv_flow_api.g_varchar2_table(411) := '41415774472C4941414D33542C454141472B4C2C6341416742314F2C4B41414B70442C514141516D442C674241416742324F2C6341477046314F2C4B41414B70442C514141516D442C67424141674269522C59414163324C2C454143314333632C4B4141';
wwv_flow_api.g_varchar2_table(412) := '4B70442C514141516D442C67424141674269522C55414155324C2C4741476A4333632C4B41414B70442C514141516D442C67424141674269522C59414163364C2C4741436A4437632C4B41414B70442C514141516D442C67424141674269522C55414155';
wwv_flow_api.g_varchar2_table(413) := '364C2C49414B2F4370422C4F4141512C5341415371422C474143622C4F41414F7867422C454141452C5541415579432C4B41414B69422C4B41414B67552C67424141674238492C4941415935512C514147374438482C6742414169422C5341415338492C';
wwv_flow_api.g_varchar2_table(414) := '47414374422C4F41414F412C4541415570492C514141512C4941414971492C4F41414F2C494141552C4B41414D2C4D4147784437552C4D41414F2C5341415338552C4541414F432C4741436E422C4941414978592C4541414F7A452C4B4143582C4F4141';
wwv_flow_api.g_varchar2_table(415) := '4F2C574145482C474141612C4B41446267642C454145492C4F41414F432C4541414B432C4D41414D7A592C4541414D30592C61414B704378422C634141652C5341415378572C454141632B472C4741476C432C4F4146476C4D2C4B41414B70442C514141';
wwv_flow_api.g_varchar2_table(416) := '5179432C694241416742364D2C4541414F6C4D2C4B41414B6F642C6B4241416B426A592C454141632B472C4941437A456C4D2C4B41414B70442C5141415130432C6742414165344D2C4541414F6C4D2C4B41414B71642C654141656C592C454141632B47';
wwv_flow_api.g_varchar2_table(417) := '2C4941436A45412C474147586B522C6B4241416D422C534141536A592C454141632B472C47414374432C494141497A482C4541414F7A452C4B4145582C49414179422C47414174426B4D2C4541414B76442C514141512C4B4141592C434151784275442C';
wwv_flow_api.g_varchar2_table(418) := '4541414F412C4541414B77492C514144412C75434143652C5341415334492C45414149432C45414149432C47414378432C4F41414F442C4741506742452C45414F43442C47414E7042432C4541414D685A2C4541414B6D502C6942414169422C4941414D';
wwv_flow_api.g_varchar2_table(419) := '364A2C4541414B2C55414157412C49414333432C4741414739492C574146412C4941415338492C4B41552F422C4F41414F76522C474147586D522C65414167422C534141536C592C454141632B472C4741436E432C494141497A482C4541414F7A452C4B';
wwv_flow_api.g_varchar2_table(420) := '4145582C49414179422C47414174426B4D2C4541414B76442C514141512C4B4141592C4341557842724D2C454141452B642C4F41414F432C4B41414B6E562C4541416174452C5141415171452C4D41414B2C53414153622C4541414F6A432C4741437044';
wwv_flow_api.g_varchar2_table(421) := '2C4941434973622C454141572C4941444176592C4541416174452C4D41414D75422C4741496C43384A2C4541414F412C4541414B77492C514141512C4941414D74532C4541625A2C5341415373622C4541415574622C47414B6A432C4F414A5571432C45';
wwv_flow_api.g_varchar2_table(422) := '41414B6D502C694241416942384A2C454141552C4F41415174622C454141512C43414374442C6541416742412C494147542C4741414775532C5541516F42674A2C43414159442C4541415574622C4F414768452C4F41414F384A2C4741475877502C5141';
wwv_flow_api.g_varchar2_table(423) := '41532C534141536F422C474143642C49414149632C45414163432C4541416942432C4541416942432C45416B4270442C47416641462C4541416B422C794641496C42432C4541416B422C674641496C42432C4541416B422C324441436C42482C47414A41';
wwv_flow_api.g_varchar2_table(424) := '412C47414A41412C45414165642C4541415570492C514141516D4A2C45414169422C7743414974426E4A2C514141516F4A2C45414169422C6B4441497A42704A2C51414151714A2C45414169422C2B4341497A436A422C45414155684A2C4D41414D2C61';
wwv_flow_api.g_varchar2_table(425) := '4141652C4941456A43394E2C4F4141532C454141472C4341476C422C494144412C4941414967592C454141616C422C4541415539592C4D41414D2C594143784269612C454141492C45414149412C45414149442C4541415768592C4F41415369592C4941';
wwv_flow_api.g_varchar2_table(426) := '43452C4D41416E43442C45414157432C474141476E4B2C4D41414D2C63414370426B4B2C45414157432C4741414B442C45414157432C4741437442764A2C514141516D4A2C45414169422C754341437A426E4A2C514141516F4A2C45414169422C694441';
wwv_flow_api.g_varchar2_table(427) := '437A42704A2C51414151714A2C45414169422C2B43414974432C4F41443242432C45414157375A2C4B41414B2C49414733432C4F41414F795A2C474149664D2C554141572C53414153432C454141576E632C47414333422C4941414979432C4541414F7A';
wwv_flow_api.g_varchar2_table(428) := '452C4B4145526D652C494143436E632C494145416F632C594141572C57414350335A2C4541414B795A2C55414155432C454141576E632C4B414333422C4D414958714E2C65414167422C5341415367502C45414151432C47414737422C47414147442C45';
wwv_flow_api.g_varchar2_table(429) := '41414F72592C5141415573592C4541414F74592C4F414376422C4F41414F2C4541495071592C4541414F2F532C4F41435067542C4541414F68542C4F4145502C494141492C4941414932532C454141452C45414147412C45414149492C4541414F72592C';
wwv_flow_api.g_varchar2_table(430) := '4F41415169592C49414335422C47414147492C4541414F4A2C4941414D4B2C4541414F4C2C474141492C4F41414F2C45414774432C4F41414F2C4741496670592C7342414175422C534141536C452C47414535422C4941414934632C4541416D422C4741';
wwv_flow_api.g_varchar2_table(431) := '436E42432C4541415778652C4B41414B70442C5141415130442C63414335422C4941414B2C494141496D652C4B414151442C45414356412C454141536C612C654141656D612C4B41437642462C4541416942432C45414153432C49414153412C47414933';
wwv_flow_api.g_varchar2_table(432) := '432C4F41414F7A652C4B41414B30652C63414163482C4541416B4235632C4941476844674F2C7342414175422C53414153684F2C47414335422C4941414936632C4541415778652C4B41414B70442C5141415130442C63414335422C4F41414F4E2C4B41';
wwv_flow_api.g_varchar2_table(433) := '414B30652C63414163462C4541415537632C49414778432B632C634141652C53414153462C4541415537632C47414339422C4941414967642C454141532C474145622C494141492C49414149432C4B4141516A642C454141612C4341437A422C47414147';
wwv_flow_api.g_varchar2_table(434) := '69642C4B4141514A2C45414550472C45414457482C45414153492C4941434C6A642C4541415969642C4741476E432C4F41414F442C49414B667269422C4541414532592C47414147374A2C534141572C53414153784F2C47414372422C4F41414F6F442C';
wwv_flow_api.g_varchar2_table(435) := '4B41414B6B462C4D41414B2C574143622C494141496B472C4541415769502C4F41414F77452C4F41414F7469422C4741433742442C454141456B4B2C4B41414B78472C4B41414D2C574141596F4C2C4741437A42412C4541415331492C4B41414B39462C';
wwv_flow_api.g_varchar2_table(436) := '474141572C474141496F44222C2266696C65223A226A71756572792D636F6D6D656E74732E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(49411560321268288099)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/jquery-comments.js.map'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2120202020206A71756572792D636F6D6D656E74732E6A7320312E352E300A202A0A202A20202020202863292032303137204A6F6F6E612054796B6B796CC3A4696E656E2C205669696D6120536F6C7574696F6E73204F790A202A20202020206A71';
wwv_flow_api.g_varchar2_table(2) := '756572792D636F6D6D656E7473206D617920626520667265656C7920646973747269627574656420756E64657220746865204D4954206C6963656E73652E0A202A2020202020466F7220616C6C2064657461696C7320616E6420646F63756D656E746174';
wwv_flow_api.g_varchar2_table(3) := '696F6E3A0A202A2020202020687474703A2F2F7669696D612E6769746875622E696F2F6A71756572792D636F6D6D656E74732F0A202A2F0A2166756E6374696F6E2874297B2266756E6374696F6E223D3D747970656F6620646566696E65262664656669';
wwv_flow_api.g_varchar2_table(4) := '6E652E616D643F646566696E65285B226A7175657279225D2C74293A226F626A656374223D3D747970656F66206D6F64756C6526266D6F64756C652E6578706F7274733F6D6F64756C652E6578706F7274733D66756E6374696F6E28652C6E297B726574';
wwv_flow_api.g_varchar2_table(5) := '75726E20766F696420303D3D3D6E2626286E3D22756E646566696E656422213D747970656F662077696E646F773F7265717569726528226A717565727922293A7265717569726528226A71756572792229286529292C74286E292C6E7D3A74286A517565';
wwv_flow_api.g_varchar2_table(6) := '7279297D282866756E6374696F6E2874297B76617220653D7B24656C3A6E756C6C2C636F6D6D656E7473427949643A7B7D2C64617461466574636865643A21312C63757272656E74536F72744B65793A22222C6F7074696F6E733A7B7D2C6576656E7473';
wwv_flow_api.g_varchar2_table(7) := '3A7B636C69636B3A22636C6F736544726F70646F776E73222C70617374653A22707265536176655061737465644174746163686D656E7473222C226B6579646F776E205B636F6E74656E746564697461626C655D223A22736176654F6E4B6579646F776E';
wwv_flow_api.g_varchar2_table(8) := '222C22666F637573205B636F6E74656E746564697461626C655D223A22736176654564697461626C65436F6E74656E74222C226B65797570205B636F6E74656E746564697461626C655D223A22636865636B4564697461626C65436F6E74656E74466F72';
wwv_flow_api.g_varchar2_table(9) := '4368616E6765222C227061737465205B636F6E74656E746564697461626C655D223A22636865636B4564697461626C65436F6E74656E74466F724368616E6765222C22696E707574205B636F6E74656E746564697461626C655D223A22636865636B4564';
wwv_flow_api.g_varchar2_table(10) := '697461626C65436F6E74656E74466F724368616E6765222C22626C7572205B636F6E74656E746564697461626C655D223A22636865636B4564697461626C65436F6E74656E74466F724368616E6765222C22636C69636B202E6E617669676174696F6E20';
wwv_flow_api.g_varchar2_table(11) := '6C695B646174612D736F72742D6B65795D223A226E617669676174696F6E456C656D656E74436C69636B6564222C22636C69636B202E6E617669676174696F6E206C692E7469746C65223A22746F67676C654E617669676174696F6E44726F70646F776E';
wwv_flow_api.g_varchar2_table(12) := '222C22636C69636B202E636F6D6D656E74696E672D6669656C642E6D61696E202E7465787461726561223A2273686F774D61696E436F6D6D656E74696E674669656C64222C22636C69636B202E636F6D6D656E74696E672D6669656C642E6D61696E202E';
wwv_flow_api.g_varchar2_table(13) := '636C6F7365223A22686964654D61696E436F6D6D656E74696E674669656C64222C22636C69636B202E636F6D6D656E74696E672D6669656C64202E7465787461726561223A22696E6372656173655465787461726561486569676874222C226368616E67';
wwv_flow_api.g_varchar2_table(14) := '65202E636F6D6D656E74696E672D6669656C64202E7465787461726561223A22696E6372656173655465787461726561486569676874207465787461726561436F6E74656E744368616E676564222C22636C69636B202E636F6D6D656E74696E672D6669';
wwv_flow_api.g_varchar2_table(15) := '656C643A6E6F74282E6D61696E29202E636C6F7365223A2272656D6F7665436F6D6D656E74696E674669656C64222C22636C69636B202E636F6D6D656E74696E672D6669656C64202E73656E642E656E61626C6564223A22706F7374436F6D6D656E7422';
wwv_flow_api.g_varchar2_table(16) := '2C22636C69636B202E636F6D6D656E74696E672D6669656C64202E7570646174652E656E61626C6564223A22707574436F6D6D656E74222C22636C69636B202E636F6D6D656E74696E672D6669656C64202E64656C6574652E656E61626C6564223A2264';
wwv_flow_api.g_varchar2_table(17) := '656C657465436F6D6D656E74222C22636C69636B202E636F6D6D656E74696E672D6669656C64202E6174746163686D656E7473202E6174746163686D656E74202E64656C657465223A2270726544656C6574654174746163686D656E74222C276368616E';
wwv_flow_api.g_varchar2_table(18) := '6765202E636F6D6D656E74696E672D6669656C64202E75706C6F61642E656E61626C656420696E7075745B747970653D2266696C65225D273A2266696C65496E7075744368616E676564222C22636C69636B206C692E636F6D6D656E7420627574746F6E';
wwv_flow_api.g_varchar2_table(19) := '2E7570766F7465223A227570766F7465436F6D6D656E74222C22636C69636B206C692E636F6D6D656E7420627574746F6E2E64656C6574652E656E61626C6564223A2264656C657465436F6D6D656E74222C22636C69636B206C692E636F6D6D656E7420';
wwv_flow_api.g_varchar2_table(20) := '2E68617368746167223A2268617368746167436C69636B6564222C22636C69636B206C692E636F6D6D656E74202E70696E67223A2270696E67436C69636B6564222C22636C69636B206C692E636F6D6D656E7420756C2E6368696C642D636F6D6D656E74';
wwv_flow_api.g_varchar2_table(21) := '73202E746F67676C652D616C6C223A22746F67676C655265706C696573222C22636C69636B206C692E636F6D6D656E7420627574746F6E2E7265706C79223A227265706C79427574746F6E436C69636B6564222C22636C69636B206C692E636F6D6D656E';
wwv_flow_api.g_varchar2_table(22) := '7420627574746F6E2E65646974223A2265646974427574746F6E436C69636B6564222C64726167656E7465723A2273686F7744726F707061626C654F7665726C6179222C2264726167656E746572202E64726F707061626C652D6F7665726C6179223A22';
wwv_flow_api.g_varchar2_table(23) := '68616E646C6544726167456E746572222C22647261676C65617665202E64726F707061626C652D6F7665726C6179223A2268616E646C65447261674C65617665466F724F7665726C6179222C2264726167656E746572202E64726F707061626C652D6F76';
wwv_flow_api.g_varchar2_table(24) := '65726C6179202E64726F707061626C65223A2268616E646C6544726167456E746572222C22647261676C65617665202E64726F707061626C652D6F7665726C6179202E64726F707061626C65223A2268616E646C65447261674C65617665466F7244726F';
wwv_flow_api.g_varchar2_table(25) := '707061626C65222C22647261676F766572202E64726F707061626C652D6F7665726C6179223A2268616E646C65447261674F766572466F724F7665726C6179222C2264726F70202E64726F707061626C652D6F7665726C6179223A2268616E646C654472';
wwv_flow_api.g_varchar2_table(26) := '6F70222C22636C69636B202E64726F70646F776E2E6175746F636F6D706C657465223A2273746F7050726F7061676174696F6E222C226D6F757365646F776E202E64726F70646F776E2E6175746F636F6D706C657465223A2273746F7050726F70616761';
wwv_flow_api.g_varchar2_table(27) := '74696F6E222C22746F7563687374617274202E64726F70646F776E2E6175746F636F6D706C657465223A2273746F7050726F7061676174696F6E227D2C67657444656661756C744F7074696F6E733A66756E6374696F6E28297B72657475726E7B70726F';
wwv_flow_api.g_varchar2_table(28) := '66696C655069637475726555524C3A22222C63757272656E7455736572497341646D696E3A21312C63757272656E745573657249643A6E756C6C2C7370696E6E657249636F6E55524C3A22222C7570766F746549636F6E55524C3A22222C7265706C7949';
wwv_flow_api.g_varchar2_table(29) := '636F6E55524C3A22222C75706C6F616449636F6E55524C3A22222C6174746163686D656E7449636F6E55524C3A22222C6E6F436F6D6D656E747349636F6E55524C3A22222C636C6F736549636F6E55524C3A22222C7465787461726561506C616365686F';
wwv_flow_api.g_varchar2_table(30) := '6C646572546578743A22416464206120636F6D6D656E74222C6E6577657374546578743A224E6577657374222C6F6C64657374546578743A224F6C64657374222C706F70756C6172546578743A22506F70756C6172222C6174746163686D656E74735465';
wwv_flow_api.g_varchar2_table(31) := '78743A224174746163686D656E7473222C73656E64546578743A2253656E64222C7265706C79546578743A225265706C79222C65646974546578743A2245646974222C656469746564546578743A22456469746564222C796F75546578743A22596F7522';
wwv_flow_api.g_varchar2_table(32) := '2C73617665546578743A2253617665222C64656C657465546578743A2244656C657465222C6E6577546578743A224E6577222C76696577416C6C5265706C696573546578743A225669657720616C6C205F5F7265706C79436F756E745F5F207265706C69';
wwv_flow_api.g_varchar2_table(33) := '6573222C686964655265706C696573546578743A2248696465207265706C696573222C6E6F436F6D6D656E7473546578743A224E6F20636F6D6D656E7473222C6E6F4174746163686D656E7473546578743A224E6F206174746163686D656E7473222C61';
wwv_flow_api.g_varchar2_table(34) := '74746163686D656E7444726F70546578743A2244726F702066696C65732068657265222C74657874466F726D61747465723A66756E6374696F6E2874297B72657475726E20747D2C656E61626C655265706C79696E673A21302C656E61626C6545646974';
wwv_flow_api.g_varchar2_table(35) := '696E673A21302C656E61626C655570766F74696E673A21302C656E61626C6544656C6574696E673A21302C656E61626C654174746163686D656E74733A21312C656E61626C6548617368746167733A21312C656E61626C6550696E67696E673A21312C65';
wwv_flow_api.g_varchar2_table(36) := '6E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965733A21312C656E61626C654E617669676174696F6E3A21302C706F7374436F6D6D656E744F6E456E7465723A21312C666F726365526573706F6E736976653A21312C72656164';
wwv_flow_api.g_varchar2_table(37) := '4F6E6C793A21312C64656661756C744E617669676174696F6E536F72744B65793A226E6577657374222C686967686C69676874436F6C6F723A2223323739336536222C64656C657465427574746F6E436F6C6F723A2223433933303243222C7363726F6C';
wwv_flow_api.g_varchar2_table(38) := '6C436F6E7461696E65723A746869732E24656C2C726F756E6450726F66696C6550696374757265733A21312C7465787461726561526F77733A322C7465787461726561526F77734F6E466F6375733A322C74657874617265614D6178526F77733A352C6D';
wwv_flow_api.g_varchar2_table(39) := '61785265706C69657356697369626C653A322C6669656C644D617070696E67733A7B69643A226964222C706172656E743A22706172656E74222C637265617465643A2263726561746564222C6D6F6469666965643A226D6F646966696564222C636F6E74';
wwv_flow_api.g_varchar2_table(40) := '656E743A22636F6E74656E74222C6174746163686D656E74733A226174746163686D656E7473222C70696E67733A2270696E6773222C63726561746F723A2263726561746F72222C66756C6C6E616D653A2266756C6C6E616D65222C70726F66696C6550';
wwv_flow_api.g_varchar2_table(41) := '69637475726555524C3A2270726F66696C655F706963747572655F75726C222C69734E65773A2269735F6E6577222C63726561746564427941646D696E3A22637265617465645F62795F61646D696E222C63726561746564427943757272656E74557365';
wwv_flow_api.g_varchar2_table(42) := '723A22637265617465645F62795F63757272656E745F75736572222C7570766F7465436F756E743A227570766F74655F636F756E74222C757365724861735570766F7465643A22757365725F6861735F7570766F746564227D2C73656172636855736572';
wwv_flow_api.g_varchar2_table(43) := '733A66756E6374696F6E28742C652C6E297B65285B5D297D2C676574436F6D6D656E74733A66756E6374696F6E28742C65297B74285B5D297D2C706F7374436F6D6D656E743A66756E6374696F6E28742C652C6E297B652874297D2C707574436F6D6D65';
wwv_flow_api.g_varchar2_table(44) := '6E743A66756E6374696F6E28742C652C6E297B652874297D2C64656C657465436F6D6D656E743A66756E6374696F6E28742C652C6E297B6528297D2C7570766F7465436F6D6D656E743A66756E6374696F6E28742C652C6E297B652874297D2C76616C69';
wwv_flow_api.g_varchar2_table(45) := '646174654174746163686D656E74733A66756E6374696F6E28742C65297B72657475726E20652874297D2C68617368746167436C69636B65643A66756E6374696F6E2874297B7D2C70696E67436C69636B65643A66756E6374696F6E2874297B7D2C7265';
wwv_flow_api.g_varchar2_table(46) := '66726573683A66756E6374696F6E28297B7D2C74696D65466F726D61747465723A66756E6374696F6E2874297B72657475726E206E657720446174652874292E746F4C6F63616C6544617465537472696E6728297D7D7D2C696E69743A66756E6374696F';
wwv_flow_api.g_varchar2_table(47) := '6E28652C6E297B76617220613B746869732E24656C3D74286E292C746869732E24656C2E616464436C61737328226A71756572792D636F6D6D656E747322292C746869732E756E64656C65676174654576656E747328292C746869732E64656C65676174';
wwv_flow_api.g_varchar2_table(48) := '654576656E747328292C613D6E6176696761746F722E757365724167656E747C7C6E6176696761746F722E76656E646F727C7C77696E646F772E6F706572612C286A51756572792E62726F777365723D6A51756572792E62726F777365727C7C7B7D292E';
wwv_flow_api.g_varchar2_table(49) := '6D6F62696C653D2F28616E64726F69647C62625C642B7C6D6565676F292E2B6D6F62696C657C6176616E74676F7C626164615C2F7C626C61636B62657272797C626C617A65727C636F6D70616C7C656C61696E657C66656E6E65637C686970746F707C69';
wwv_flow_api.g_varchar2_table(50) := '656D6F62696C657C697028686F6E657C6F64297C697269737C6B696E646C657C6C6765207C6D61656D6F7C6D6964707C6D6D707C6D6F62696C652E2B66697265666F787C6E657466726F6E747C6F70657261206D286F627C696E29697C70616C6D28206F';
wwv_flow_api.g_varchar2_table(51) := '73293F7C70686F6E657C70286978697C7265295C2F7C706C75636B65727C706F636B65747C7073707C73657269657328347C3629307C73796D6269616E7C7472656F7C75705C2E2862726F777365727C6C696E6B297C766F6461666F6E657C7761707C77';
wwv_flow_api.g_varchar2_table(52) := '696E646F77732063657C7864617C7869696E6F2F692E746573742861297C7C2F313230377C363331307C363539307C3367736F7C347468707C35305B312D365D697C373730737C383032737C612077617C616261637C61632865727C6F6F7C735C2D297C';
wwv_flow_api.g_varchar2_table(53) := '6169286B6F7C726E297C616C2861767C63617C636F297C616D6F697C616E2865787C6E797C7977297C617074757C61722863687C676F297C61732874657C7573297C617474777C61752864697C5C2D6D7C72207C7320297C6176616E7C626528636B7C6C';
wwv_flow_api.g_varchar2_table(54) := '6C7C6E71297C6269286C627C7264297C626C2861637C617A297C627228657C7629777C62756D627C62775C2D286E7C75297C6335355C2F7C636170697C636377617C63646D5C2D7C63656C6C7C6368746D7C636C64637C636D645C2D7C636F286D707C6E';
wwv_flow_api.g_varchar2_table(55) := '64297C637261777C64612869747C6C6C7C6E67297C646274657C64635C2D737C646576697C646963617C646D6F627C646F28637C70296F7C64732831327C5C2D64297C656C2834397C6169297C656D286C327C756C297C65722869637C6B30297C65736C';
wwv_flow_api.g_varchar2_table(56) := '387C657A285B342D375D307C6F737C77617C7A65297C666574637C666C79285C2D7C5F297C673120757C673536307C67656E657C67665C2D357C675C2D6D6F7C676F285C2E777C6F64297C67722861647C756E297C686169657C686369747C68645C2D28';
wwv_flow_api.g_varchar2_table(57) := '6D7C707C74297C6865695C2D7C68692870747C7461297C68702820697C6970297C68735C2D637C68742863285C2D7C207C5F7C617C677C707C737C74297C7470297C68752861777C7463297C695C2D2832307C676F7C6D61297C693233307C6961632820';
wwv_flow_api.g_varchar2_table(58) := '7C5C2D7C5C2F297C6962726F7C696465617C696730317C696B6F6D7C696D316B7C696E6E6F7C697061717C697269737C6A6128747C7629617C6A62726F7C6A656D757C6A6967737C6B6464697C6B656A697C6B677428207C5C2F297C6B6C6F6E7C6B7074';
wwv_flow_api.g_varchar2_table(59) := '207C6B77635C2D7C6B796F28637C6B297C6C65286E6F7C7869297C6C672820677C5C2F286B7C6C7C75297C35307C35347C5C2D5B612D775D297C6C6962777C6C796E787C6D315C2D777C6D3367617C6D35305C2F7C6D612874657C75697C786F297C6D63';
wwv_flow_api.g_varchar2_table(60) := '2830317C32317C6361297C6D5C2D63727C6D652872637C7269297C6D69286F387C6F617C7473297C6D6D65667C6D6F2830317C30327C62697C64657C646F7C74285C2D7C207C6F7C76297C7A7A297C6D742835307C70317C7620297C6D7762707C6D7977';
wwv_flow_api.g_varchar2_table(61) := '617C6E31305B302D325D7C6E32305B322D335D7C6E333028307C32297C6E353028307C327C35297C6E37283028307C31297C3130297C6E652828637C6D295C2D7C6F6E7C74667C77667C77677C7774297C6E6F6B28367C69297C6E7A70687C6F32696D7C';
wwv_flow_api.g_varchar2_table(62) := '6F702874697C7776297C6F72616E7C6F7767317C703830307C70616E28617C647C74297C706478677C70672831337C5C2D285B312D385D7C6329297C7068696C7C706972657C706C2861797C7563297C706E5C2D327C706F28636B7C72747C7365297C70';
wwv_flow_api.g_varchar2_table(63) := '726F787C7073696F7C70745C2D677C71615C2D617C71632830377C31327C32317C33327C36307C5C2D5B322D375D7C695C2D297C7174656B7C723338307C723630307C72616B737C72696D397C726F2876657C7A6F297C7335355C2F7C73612867657C6D';
wwv_flow_api.g_varchar2_table(64) := '617C6D6D7C6D737C6E797C7661297C73632830317C685C2D7C6F6F7C705C2D297C73646B5C2F7C73652863285C2D7C307C31297C34377C6D637C6E647C7269297C7367685C2D7C736861727C736965285C2D7C6D297C736B5C2D307C736C2834357C6964';
wwv_flow_api.g_varchar2_table(65) := '297C736D28616C7C61727C62337C69747C7435297C736F2866747C6E79297C73702830317C685C2D7C765C2D7C7620297C73792830317C6D62297C74322831387C3530297C74362830307C31307C3138297C74612867747C6C6B297C74636C5C2D7C7464';
wwv_flow_api.g_varchar2_table(66) := '675C2D7C74656C28697C6D297C74696D5C2D7C745C2D6D6F7C746F28706C7C7368297C74732837307C6D5C2D7C6D337C6D35297C74785C2D397C7570285C2E627C67317C7369297C757473747C763430307C763735307C766572697C76692872677C7465';
wwv_flow_api.g_varchar2_table(67) := '297C766B2834307C355B302D335D7C5C2D76297C766D34307C766F64617C76756C637C76782835327C35337C36307C36317C37307C38307C38317C38337C38357C3938297C773363285C2D7C20297C776562637C776869747C77692867207C6E637C6E77';
wwv_flow_api.g_varchar2_table(68) := '297C776D6C627C776F6E757C783730307C7961735C2D7C796F75727C7A65746F7C7A74655C2D2F692E7465737428612E73756273747228302C3429292C742E62726F777365722E6D6F62696C652626746869732E24656C2E616464436C61737328226D6F';
wwv_flow_api.g_varchar2_table(69) := '62696C6522292C746869732E6F7074696F6E733D742E657874656E642821302C7B7D2C746869732E67657444656661756C744F7074696F6E7328292C65292C746869732E6F7074696F6E732E726561644F6E6C792626746869732E24656C2E616464436C';
wwv_flow_api.g_varchar2_table(70) := '6173732822726561642D6F6E6C7922292C746869732E63757272656E74536F72744B65793D746869732E6F7074696F6E732E64656661756C744E617669676174696F6E536F72744B65792C746869732E6372656174654373734465636C61726174696F6E';
wwv_flow_api.g_varchar2_table(71) := '7328292C746869732E666574636844617461416E6452656E64657228297D2C64656C65676174654576656E74733A66756E6374696F6E28297B746869732E62696E644576656E7473282131297D2C756E64656C65676174654576656E74733A66756E6374';
wwv_flow_api.g_varchar2_table(72) := '696F6E28297B746869732E62696E644576656E7473282130297D2C62696E644576656E74733A66756E6374696F6E2865297B766172206E3D653F226F6666223A226F6E223B666F7228766172206120696E20746869732E6576656E7473297B7661722069';
wwv_flow_api.g_varchar2_table(73) := '3D612E73706C697428222022295B305D2C6F3D612E73706C697428222022292E736C6963652831292E6A6F696E28222022292C733D746869732E6576656E74735B615D2E73706C697428222022293B666F7228766172207220696E207329696628732E68';
wwv_flow_api.g_varchar2_table(74) := '61734F776E50726F7065727479287229297B766172206C3D746869735B735B725D5D3B6C3D742E70726F7879286C2C74686973292C22223D3D6F3F746869732E24656C5B6E5D28692C6C293A746869732E24656C5B6E5D28692C6F2C6C297D7D7D2C6665';
wwv_flow_api.g_varchar2_table(75) := '74636844617461416E6452656E6465723A66756E6374696F6E28297B76617220653D746869733B746869732E636F6D6D656E7473427949643D7B7D2C746869732E24656C2E656D70747928292C746869732E63726561746548544D4C28292C746869732E';
wwv_flow_api.g_varchar2_table(76) := '6F7074696F6E732E676574436F6D6D656E7473282866756E6374696F6E286E297B76617220613D6E2E6D6170282866756E6374696F6E2874297B72657475726E20652E637265617465436F6D6D656E744D6F64656C2874297D29293B652E736F7274436F';
wwv_flow_api.g_varchar2_table(77) := '6D6D656E747328612C226F6C6465737422292C742861292E65616368282866756E6374696F6E28742C6E297B652E616464436F6D6D656E74546F446174614D6F64656C286E297D29292C652E64617461466574636865643D21302C652E72656E64657228';
wwv_flow_api.g_varchar2_table(78) := '297D29297D2C66657463684E6578743A66756E6374696F6E28297B76617220653D746869732C6E3D746869732E6372656174655370696E6E657228293B746869732E24656C2E66696E642822756C23636F6D6D656E742D6C69737422292E617070656E64';
wwv_flow_api.g_varchar2_table(79) := '286E293B746869732E6F7074696F6E732E676574436F6D6D656E7473282866756E6374696F6E2861297B742861292E65616368282866756E6374696F6E28742C6E297B652E637265617465436F6D6D656E74286E297D29292C6E2E72656D6F766528297D';
wwv_flow_api.g_varchar2_table(80) := '292C2866756E6374696F6E28297B6E2E72656D6F766528297D29297D2C637265617465436F6D6D656E744D6F64656C3A66756E6374696F6E2874297B76617220653D746869732E6170706C79496E7465726E616C4D617070696E67732874293B72657475';
wwv_flow_api.g_varchar2_table(81) := '726E20652E6368696C64733D5B5D2C652E6861734174746163686D656E74733D66756E6374696F6E28297B72657475726E20652E6174746163686D656E74732E6C656E6774683E307D2C657D2C616464436F6D6D656E74546F446174614D6F64656C3A66';
wwv_flow_api.g_varchar2_table(82) := '756E6374696F6E2874297B742E696420696E20746869732E636F6D6D656E7473427949647C7C28746869732E636F6D6D656E7473427949645B742E69645D3D742C742E706172656E742626746869732E6765744F757465726D6F7374506172656E742874';
wwv_flow_api.g_varchar2_table(83) := '2E706172656E74292E6368696C64732E7075736828742E696429297D2C757064617465436F6D6D656E744D6F64656C3A66756E6374696F6E2865297B742E657874656E6428746869732E636F6D6D656E7473427949645B652E69645D2C65297D2C72656E';
wwv_flow_api.g_varchar2_table(84) := '6465723A66756E6374696F6E28297B746869732E6461746146657463686564262628746869732E73686F77416374697665436F6E7461696E657228292C746869732E637265617465436F6D6D656E747328292C746869732E6F7074696F6E732E656E6162';
wwv_flow_api.g_varchar2_table(85) := '6C654174746163686D656E74732626746869732E6F7074696F6E732E656E61626C654E617669676174696F6E2626746869732E6372656174654174746163686D656E747328292C746869732E24656C2E66696E6428223E202E7370696E6E657222292E72';
wwv_flow_api.g_varchar2_table(86) := '656D6F766528292C746869732E6F7074696F6E732E726566726573682829297D2C73686F77416374697665436F6E7461696E65723A66756E6374696F6E28297B76617220743D746869732E24656C2E66696E6428222E6E617669676174696F6E206C695B';
wwv_flow_api.g_varchar2_table(87) := '646174612D636F6E7461696E65722D6E616D655D2E61637469766522292E646174612822636F6E7461696E65722D6E616D6522292C653D746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D22272B742B27225D27293B652E73';
wwv_flow_api.g_varchar2_table(88) := '69626C696E677328225B646174612D636F6E7461696E65725D22292E6869646528292C652E73686F7728297D2C637265617465436F6D6D656E74733A66756E6374696F6E28297B76617220653D746869733B746869732E24656C2E66696E64282223636F';
wwv_flow_api.g_varchar2_table(89) := '6D6D656E742D6C69737422292E72656D6F766528293B766172206E3D7428223C756C2F3E222C7B69643A22636F6D6D656E742D6C697374222C636C6173733A226D61696E227D292C613D5B5D2C693D5B5D3B7428746869732E676574436F6D6D656E7473';
wwv_flow_api.g_varchar2_table(90) := '2829292E65616368282866756E6374696F6E28742C65297B6E756C6C3D3D652E706172656E743F612E707573682865293A692E707573682865297D29292C746869732E736F7274436F6D6D656E747328612C746869732E63757272656E74536F72744B65';
wwv_flow_api.g_varchar2_table(91) := '79292C742861292E65616368282866756E6374696F6E28742C61297B652E616464436F6D6D656E7428612C6E297D29292C746869732E736F7274436F6D6D656E747328692C226F6C6465737422292C742869292E65616368282866756E6374696F6E2874';
wwv_flow_api.g_varchar2_table(92) := '2C61297B652E616464436F6D6D656E7428612C6E297D29292C746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D22636F6D6D656E7473225D27292E70726570656E64286E297D2C6372656174654174746163686D656E74733A';
wwv_flow_api.g_varchar2_table(93) := '66756E6374696F6E28297B76617220653D746869733B746869732E24656C2E66696E642822236174746163686D656E742D6C69737422292E72656D6F766528293B766172206E3D7428223C756C2F3E222C7B69643A226174746163686D656E742D6C6973';
wwv_flow_api.g_varchar2_table(94) := '74222C636C6173733A226D61696E227D292C613D746869732E6765744174746163686D656E747328293B746869732E736F7274436F6D6D656E747328612C226E657765737422292C742861292E65616368282866756E6374696F6E28742C61297B652E61';
wwv_flow_api.g_varchar2_table(95) := '64644174746163686D656E7428612C6E297D29292C746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D226174746163686D656E7473225D27292E70726570656E64286E297D2C616464436F6D6D656E743A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(96) := '28742C652C6E297B653D657C7C746869732E24656C2E66696E64282223636F6D6D656E742D6C69737422293B76617220613D746869732E637265617465436F6D6D656E74456C656D656E742874293B696628742E706172656E74297B76617220693D652E';
wwv_flow_api.g_varchar2_table(97) := '66696E6428272E636F6D6D656E745B646174612D69643D22272B742E706172656E742B27225D27292C6F3D7061727365496E7428692E637373282270616464696E672D6C6566742229292B32352C733D692E66696E6428222E6368696C642D636F6D6D65';
wwv_flow_api.g_varchar2_table(98) := '6E747322292E6368696C6472656E28226C692E636F6D6D656E7422293B746869732E726552656E646572436F6D6D656E74416374696F6E42617228742E706172656E74293B76617220723D692E706172656E747328222E636F6D6D656E7422292E6C6173';
wwv_flow_api.g_varchar2_table(99) := '7428293B303D3D722E6C656E677468262628723D69292C612E637373282270616464696E672D6C656674222C6F2B22707822292C732E6C656E6774683F732E6C61737428292E61667465722861293A692E66696E6428222E6368696C642D636F6D6D656E';
wwv_flow_api.g_varchar2_table(100) := '747322292E70726570656E642861292C746869732E757064617465546F67676C65416C6C427574746F6E2872297D656C736520612E637373282270616464696E672D6C656674222C2230707822292C6E3F652E70726570656E642861293A652E61707065';
wwv_flow_api.g_varchar2_table(101) := '6E642861297D2C6164644174746163686D656E743A66756E6374696F6E28742C65297B653D657C7C746869732E24656C2E66696E642822236174746163686D656E742D6C69737422293B766172206E3D746869732E637265617465436F6D6D656E74456C';
wwv_flow_api.g_varchar2_table(102) := '656D656E742874293B652E70726570656E64286E297D2C72656D6F7665436F6D6D656E743A66756E6374696F6E2865297B766172206E3D746869732C613D746869732E636F6D6D656E7473427949645B655D2C693D746869732E6765744368696C64436F';
wwv_flow_api.g_varchar2_table(103) := '6D6D656E747328612E6964293B696628742869292E65616368282866756E6374696F6E28742C65297B6E2E72656D6F7665436F6D6D656E7428652E6964297D29292C612E706172656E74297B766172206F3D746869732E6765744F757465726D6F737450';
wwv_flow_api.g_varchar2_table(104) := '6172656E7428612E706172656E74292C733D6F2E6368696C64732E696E6465784F6628612E6964293B6F2E6368696C64732E73706C69636528732C31297D64656C65746520746869732E636F6D6D656E7473427949645B655D3B76617220723D74686973';
wwv_flow_api.g_varchar2_table(105) := '2E24656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B652B27225D27292C6C3D722E706172656E747328226C692E636F6D6D656E7422292E6C61737428293B722E72656D6F766528292C746869732E757064617465546F6767';
wwv_flow_api.g_varchar2_table(106) := '6C65416C6C427574746F6E286C297D2C70726544656C6574654174746163686D656E743A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292E706172656E747328222E636F6D6D656E74696E672D6669656C6422';
wwv_flow_api.g_varchar2_table(107) := '292E666972737428293B7428652E63757272656E74546172676574292E706172656E747328222E6174746163686D656E7422292E666972737428292E72656D6F766528292C746869732E746F67676C6553617665427574746F6E286E297D2C7072655361';
wwv_flow_api.g_varchar2_table(108) := '76654174746163686D656E74733A66756E6374696F6E28652C6E297B76617220613D746869733B696628652E6C656E677468297B6E7C7C286E3D746869732E24656C2E66696E6428222E636F6D6D656E74696E672D6669656C642E6D61696E2229293B76';
wwv_flow_api.g_varchar2_table(109) := '617220693D6E2E66696E6428222E636F6E74726F6C2D726F77202E75706C6F616422292C6F3D286E2E686173436C61737328226D61696E22292C6E2E66696E6428222E636F6E74726F6C2D726F77202E6174746163686D656E74732229292C733D742865';
wwv_flow_api.g_varchar2_table(110) := '292E6D6170282866756E6374696F6E28742C65297B72657475726E7B6D696D655F747970653A652E747970652C66696C653A657D7D29292C723D746869732E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C64286E293B';
wwv_flow_api.g_varchar2_table(111) := '733D732E66696C746572282866756E6374696F6E28652C6E297B76617220613D21313B72657475726E20742872292E65616368282866756E6374696F6E28742C65297B6E2E66696C652E6E616D653D3D652E66696C652E6E616D6526266E2E66696C652E';
wwv_flow_api.g_varchar2_table(112) := '73697A653D3D652E66696C652E73697A65262628613D2130297D29292C21617D29292C6E2E686173436C61737328226D61696E222926266E2E66696E6428222E746578746172656122292E747269676765722822636C69636B22292C746869732E736574';
wwv_flow_api.g_varchar2_table(113) := '427574746F6E537461746528692C21312C2130292C746869732E6F7074696F6E732E76616C69646174654174746163686D656E747328732C2866756E6374696F6E2865297B652E6C656E677468262628742865292E65616368282866756E6374696F6E28';
wwv_flow_api.g_varchar2_table(114) := '742C65297B766172206E3D612E6372656174654174746163686D656E74546167456C656D656E7428652C2130293B6F2E617070656E64286E297D29292C612E746F67676C6553617665427574746F6E286E29292C612E736574427574746F6E5374617465';
wwv_flow_api.g_varchar2_table(115) := '28692C21302C2131297D29297D692E66696E642822696E70757422292E76616C282222297D2C757064617465546F67676C65416C6C427574746F6E3A66756E6374696F6E2865297B6966286E756C6C213D746869732E6F7074696F6E732E6D6178526570';
wwv_flow_api.g_varchar2_table(116) := '6C69657356697369626C65297B766172206E3D652E66696E6428222E6368696C642D636F6D6D656E747322292C613D6E2E66696E6428222E636F6D6D656E7422292E6E6F7428222E68696464656E22292C693D6E2E66696E6428226C692E746F67676C65';
wwv_flow_api.g_varchar2_table(117) := '2D616C6C22293B696628612E72656D6F7665436C6173732822746F67676C61626C652D7265706C7922292C303D3D3D746869732E6F7074696F6E732E6D61785265706C69657356697369626C6529766172206F3D613B656C7365206F3D612E736C696365';
wwv_flow_api.g_varchar2_table(118) := '28302C2D746869732E6F7074696F6E732E6D61785265706C69657356697369626C65293B6966286F2E616464436C6173732822746F67676C61626C652D7265706C7922292C692E66696E6428227370616E2E7465787422292E7465787428293D3D746869';
wwv_flow_api.g_varchar2_table(119) := '732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E686964655265706C696573546578742926266F2E616464436C617373282276697369626C6522292C612E6C656E6774683E746869732E6F7074696F6E732E6D';
wwv_flow_api.g_varchar2_table(120) := '61785265706C69657356697369626C65297B69662821692E6C656E677468297B693D7428223C6C692F3E222C7B636C6173733A22746F67676C652D616C6C20686967686C696768742D666F6E742D626F6C64227D293B76617220733D7428223C7370616E';
wwv_flow_api.g_varchar2_table(121) := '2F3E222C7B636C6173733A2274657874227D292C723D7428223C7370616E2F3E222C7B636C6173733A226361726574227D293B692E617070656E642873292E617070656E642872292C6E2E70726570656E642869297D746869732E736574546F67676C65';
wwv_flow_api.g_varchar2_table(122) := '416C6C427574746F6E5465787428692C2131297D656C736520692E72656D6F766528297D7D2C757064617465546F67676C65416C6C427574746F6E733A66756E6374696F6E28297B76617220653D746869732C6E3D746869732E24656C2E66696E642822';
wwv_flow_api.g_varchar2_table(123) := '23636F6D6D656E742D6C69737422293B6E2E66696E6428222E636F6D6D656E7422292E72656D6F7665436C617373282276697369626C6522292C6E2E6368696C6472656E28222E636F6D6D656E7422292E65616368282866756E6374696F6E286E2C6129';
wwv_flow_api.g_varchar2_table(124) := '7B652E757064617465546F67676C65416C6C427574746F6E2874286129297D29297D2C736F7274436F6D6D656E74733A66756E6374696F6E28742C65297B766172206E3D746869733B22706F70756C6172697479223D3D653F742E736F7274282866756E';
wwv_flow_api.g_varchar2_table(125) := '6374696F6E28742C65297B76617220613D742E6368696C64732E6C656E6774682C693D652E6368696C64732E6C656E6774683B6966286E2E6F7074696F6E732E656E61626C655570766F74696E67262628612B3D742E7570766F7465436F756E742C692B';
wwv_flow_api.g_varchar2_table(126) := '3D652E7570766F7465436F756E74292C69213D612972657475726E20692D613B766172206F3D6E6577204461746528742E63726561746564292E67657454696D6528293B72657475726E206E6577204461746528652E63726561746564292E6765745469';
wwv_flow_api.g_varchar2_table(127) := '6D6528292D6F7D29293A742E736F7274282866756E6374696F6E28742C6E297B76617220613D6E6577204461746528742E63726561746564292E67657454696D6528292C693D6E65772044617465286E2E63726561746564292E67657454696D6528293B';
wwv_flow_api.g_varchar2_table(128) := '72657475726E226F6C64657374223D3D653F612D693A692D617D29297D2C736F7274416E645265417272616E6765436F6D6D656E74733A66756E6374696F6E2865297B766172206E3D746869732E24656C2E66696E64282223636F6D6D656E742D6C6973';
wwv_flow_api.g_varchar2_table(129) := '7422292C613D746869732E676574436F6D6D656E747328292E66696C746572282866756E6374696F6E2874297B72657475726E21742E706172656E747D29293B746869732E736F7274436F6D6D656E747328612C65292C742861292E6561636828286675';
wwv_flow_api.g_varchar2_table(130) := '6E6374696F6E28742C65297B76617220613D6E2E66696E6428223E206C692E636F6D6D656E745B646174612D69643D222B652E69642B225D22293B6E2E617070656E642861297D29297D2C73686F77416374697665536F72743A66756E6374696F6E2829';
wwv_flow_api.g_varchar2_table(131) := '7B76617220743D746869732E24656C2E66696E6428272E6E617669676174696F6E206C695B646174612D736F72742D6B65793D22272B746869732E63757272656E74536F72744B65792B27225D27293B746869732E24656C2E66696E6428222E6E617669';
wwv_flow_api.g_varchar2_table(132) := '676174696F6E206C6922292E72656D6F7665436C617373282261637469766522292C742E616464436C617373282261637469766522293B76617220653D746869732E24656C2E66696E6428222E6E617669676174696F6E202E7469746C6522293B696628';
wwv_flow_api.g_varchar2_table(133) := '226174746163686D656E747322213D746869732E63757272656E74536F72744B657929652E616464436C617373282261637469766522292C652E66696E64282268656164657222292E68746D6C28742E666972737428292E68746D6C2829293B656C7365';
wwv_flow_api.g_varchar2_table(134) := '7B766172206E3D746869732E24656C2E66696E6428222E6E617669676174696F6E20756C2E64726F70646F776E22292E6368696C6472656E28292E666972737428293B652E66696E64282268656164657222292E68746D6C286E2E68746D6C2829297D74';
wwv_flow_api.g_varchar2_table(135) := '6869732E73686F77416374697665436F6E7461696E657228297D2C666F726365526573706F6E736976653A66756E6374696F6E28297B746869732E24656C2E616464436C6173732822726573706F6E7369766522297D2C636C6F736544726F70646F776E';
wwv_flow_api.g_varchar2_table(136) := '733A66756E6374696F6E28297B746869732E24656C2E66696E6428222E64726F70646F776E22292E6869646528297D2C707265536176655061737465644174746163686D656E74733A66756E6374696F6E2865297B766172206E3D652E6F726967696E61';
wwv_flow_api.g_varchar2_table(137) := '6C4576656E742E636C6970626F617264446174612E66696C65733B6966286E2626313D3D6E2E6C656E677468297B76617220612C693D7428652E746172676574292E706172656E747328222E636F6D6D656E74696E672D6669656C6422292E6669727374';
wwv_flow_api.g_varchar2_table(138) := '28293B692E6C656E677468262628613D69292C746869732E707265536176654174746163686D656E7473286E2C61292C652E70726576656E7444656661756C7428297D7D2C736176654F6E4B6579646F776E3A66756E6374696F6E2865297B6966283133';
wwv_flow_api.g_varchar2_table(139) := '3D3D652E6B6579436F6465297B766172206E3D652E6D6574614B65797C7C652E6374726C4B65793B696628746869732E6F7074696F6E732E706F7374436F6D6D656E744F6E456E7465727C7C6E297428652E63757272656E74546172676574292E736962';
wwv_flow_api.g_varchar2_table(140) := '6C696E677328222E636F6E74726F6C2D726F7722292E66696E6428222E7361766522292E747269676765722822636C69636B22292C652E73746F7050726F7061676174696F6E28292C652E70726576656E7444656661756C7428297D7D2C736176654564';
wwv_flow_api.g_varchar2_table(141) := '697461626C65436F6E74656E743A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574293B6E2E6461746128226265666F7265222C6E2E68746D6C2829297D2C636865636B4564697461626C65436F6E74656E74466F';
wwv_flow_api.g_varchar2_table(142) := '724368616E67653A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574293B74286E5B305D2E6368696C644E6F646573292E65616368282866756E6374696F6E28297B746869732E6E6F6465547970653D3D4E6F6465';
wwv_flow_api.g_varchar2_table(143) := '2E544558545F4E4F44452626303D3D746869732E6C656E6774682626746869732E72656D6F76654E6F64652626746869732E72656D6F76654E6F646528297D29292C6E2E6461746128226265666F72652229213D6E2E68746D6C28292626286E2E646174';
wwv_flow_api.g_varchar2_table(144) := '6128226265666F7265222C6E2E68746D6C2829292C6E2E7472696767657228226368616E67652229297D2C6E617669676174696F6E456C656D656E74436C69636B65643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172';
wwv_flow_api.g_varchar2_table(145) := '676574292E6461746128292E736F72744B65793B226174746163686D656E7473223D3D6E3F746869732E6372656174654174746163686D656E747328293A746869732E736F7274416E645265417272616E6765436F6D6D656E7473286E292C746869732E';
wwv_flow_api.g_varchar2_table(146) := '63757272656E74536F72744B65793D6E2C746869732E73686F77416374697665536F727428297D2C746F67676C654E617669676174696F6E44726F70646F776E3A66756E6374696F6E2865297B652E73746F7050726F7061676174696F6E28292C742865';
wwv_flow_api.g_varchar2_table(147) := '2E63757272656E74546172676574292E66696E6428227E202E64726F70646F776E22292E746F67676C6528297D2C73686F774D61696E436F6D6D656E74696E674669656C643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E7454';
wwv_flow_api.g_varchar2_table(148) := '6172676574293B6E2E7369626C696E677328222E636F6E74726F6C2D726F7722292E73686F7728292C6E2E706172656E7428292E66696E6428222E636C6F736522292E73686F7728292C6E2E706172656E7428292E66696E6428222E75706C6F61642E69';
wwv_flow_api.g_varchar2_table(149) := '6E6C696E652D627574746F6E22292E6869646528292C6E2E666F63757328297D2C686964654D61696E436F6D6D656E74696E674669656C643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292C613D74686973';
wwv_flow_api.g_varchar2_table(150) := '2E24656C2E66696E6428222E636F6D6D656E74696E672D6669656C642E6D61696E22292C693D612E66696E6428222E746578746172656122292C6F3D612E66696E6428222E636F6E74726F6C2D726F7722293B746869732E636C65617254657874617265';
wwv_flow_api.g_varchar2_table(151) := '612869292C612E66696E6428222E6174746163686D656E747322292E656D70747928292C746869732E746F67676C6553617665427574746F6E2861292C746869732E61646A757374546578746172656148656967687428692C2131292C6F2E6869646528';
wwv_flow_api.g_varchar2_table(152) := '292C6E2E6869646528292C692E706172656E7428292E66696E6428222E75706C6F61642E696E6C696E652D627574746F6E22292E73686F7728292C692E626C757228297D2C696E63726561736554657874617265614865696768743A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(153) := '2865297B766172206E3D7428652E63757272656E74546172676574293B746869732E61646A7573745465787461726561486569676874286E2C2130297D2C7465787461726561436F6E74656E744368616E6765643A66756E6374696F6E2865297B766172';
wwv_flow_api.g_varchar2_table(154) := '206E3D7428652E63757272656E74546172676574293B696628216E2E66696E6428222E7265706C792D746F2E74616722292E6C656E677468296966286E2E617474722822646174612D636F6D6D656E742229297B76617220613D6E2E706172656E747328';
wwv_flow_api.g_varchar2_table(155) := '226C692E636F6D6D656E7422293B696628612E6C656E6774683E31297B76617220693D612E6C61737428292E646174612822696422293B6E2E617474722822646174612D706172656E74222C69297D7D656C73657B693D6E2E706172656E747328226C69';
wwv_flow_api.g_varchar2_table(156) := '2E636F6D6D656E7422292E6C61737428292E646174612822696422293B6E2E617474722822646174612D706172656E74222C69297D766172206F3D6E2E706172656E747328222E636F6D6D656E74696E672D6669656C6422292E666972737428293B6E5B';
wwv_flow_api.g_varchar2_table(157) := '305D2E7363726F6C6C4865696768743E6E2E6F7574657248656967687428293F6F2E616464436C6173732822636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C6522293A6F2E72656D6F7665436C6173732822636F6D6D656E74696E672D';
wwv_flow_api.g_varchar2_table(158) := '6669656C642D7363726F6C6C61626C6522292C746869732E746F67676C6553617665427574746F6E286F297D2C746F67676C6553617665427574746F6E3A66756E6374696F6E2874297B76617220652C6E3D742E66696E6428222E746578746172656122';
wwv_flow_api.g_varchar2_table(159) := '292C613D6E2E7369626C696E677328222E636F6E74726F6C2D726F7722292E66696E6428222E7361766522292C693D746869732E6765745465787461726561436F6E74656E74286E2C2130292C6F3D746869732E6765744174746163686D656E74734672';
wwv_flow_api.g_varchar2_table(160) := '6F6D436F6D6D656E74696E674669656C642874293B696628636F6D6D656E744D6F64656C3D746869732E636F6D6D656E7473427949645B6E2E617474722822646174612D636F6D6D656E7422295D297B76617220732C723D69213D636F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(161) := '64656C2E636F6E74656E743B636F6D6D656E744D6F64656C2E706172656E74262628733D636F6D6D656E744D6F64656C2E706172656E742E746F537472696E672829293B766172206C3D6E2E617474722822646174612D706172656E742229213D732C63';
wwv_flow_api.g_varchar2_table(162) := '3D21313B696628746869732E6F7074696F6E732E656E61626C654174746163686D656E7473297B76617220643D636F6D6D656E744D6F64656C2E6174746163686D656E74732E6D6170282866756E6374696F6E2874297B72657475726E20742E69647D29';
wwv_flow_api.g_varchar2_table(163) := '292C703D6F2E6D6170282866756E6374696F6E2874297B72657475726E20742E69647D29293B633D21746869732E617265417272617973457175616C28642C70297D653D727C7C6C7C7C637D656C736520653D426F6F6C65616E28692E6C656E67746829';
wwv_flow_api.g_varchar2_table(164) := '7C7C426F6F6C65616E286F2E6C656E677468293B612E746F67676C65436C6173732822656E61626C6564222C65297D2C72656D6F7665436F6D6D656E74696E674669656C643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E7454';
wwv_flow_api.g_varchar2_table(165) := '6172676574293B6E2E7369626C696E677328222E746578746172656122292E617474722822646174612D636F6D6D656E74222926266E2E706172656E747328226C692E636F6D6D656E7422292E666972737428292E72656D6F7665436C61737328226564';
wwv_flow_api.g_varchar2_table(166) := '697422292C6E2E706172656E747328222E636F6D6D656E74696E672D6669656C6422292E666972737428292E72656D6F766528297D2C706F7374436F6D6D656E743A66756E6374696F6E2865297B766172206E3D746869732C613D7428652E6375727265';
wwv_flow_api.g_varchar2_table(167) := '6E74546172676574292C693D612E706172656E747328222E636F6D6D656E74696E672D6669656C6422292E666972737428293B746869732E736574427574746F6E537461746528612C21312C2130293B766172206F3D746869732E637265617465436F6D';
wwv_flow_api.g_varchar2_table(168) := '6D656E744A534F4E2869293B6F3D746869732E6170706C7945787465726E616C4D617070696E6773286F293B746869732E6F7074696F6E732E706F7374436F6D6D656E74286F2C2866756E6374696F6E2874297B6E2E637265617465436F6D6D656E7428';
wwv_flow_api.g_varchar2_table(169) := '74292C692E66696E6428222E636C6F736522292E747269676765722822636C69636B22292C6E2E736574427574746F6E537461746528612C21312C2131297D292C2866756E6374696F6E28297B6E2E736574427574746F6E537461746528612C21302C21';
wwv_flow_api.g_varchar2_table(170) := '31297D29297D2C637265617465436F6D6D656E743A66756E6374696F6E2874297B76617220653D746869732E637265617465436F6D6D656E744D6F64656C2874293B746869732E616464436F6D6D656E74546F446174614D6F64656C2865293B76617220';
wwv_flow_api.g_varchar2_table(171) := '6E3D746869732E24656C2E66696E64282223636F6D6D656E742D6C69737422292C613D226E6577657374223D3D746869732E63757272656E74536F72744B65793B746869732E616464436F6D6D656E7428652C6E2C61292C226174746163686D656E7473';
wwv_flow_api.g_varchar2_table(172) := '223D3D746869732E63757272656E74536F72744B65792626652E6861734174746163686D656E747328292626746869732E6164644174746163686D656E742865297D2C707574436F6D6D656E743A66756E6374696F6E2865297B766172206E3D74686973';
wwv_flow_api.g_varchar2_table(173) := '2C613D7428652E63757272656E74546172676574292C693D612E706172656E747328222E636F6D6D656E74696E672D6669656C6422292E666972737428292C6F3D692E66696E6428222E746578746172656122293B746869732E736574427574746F6E53';
wwv_flow_api.g_varchar2_table(174) := '7461746528612C21312C2130293B76617220733D742E657874656E64287B7D2C746869732E636F6D6D656E7473427949645B6F2E617474722822646174612D636F6D6D656E7422295D293B742E657874656E6428732C7B706172656E743A6F2E61747472';
wwv_flow_api.g_varchar2_table(175) := '2822646174612D706172656E7422297C7C6E756C6C2C636F6E74656E743A746869732E6765745465787461726561436F6E74656E74286F292C70696E67733A746869732E67657450696E6773286F292C6D6F6469666965643A286E65772044617465292E';
wwv_flow_api.g_varchar2_table(176) := '67657454696D6528292C6174746163686D656E74733A746869732E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C642869297D292C733D746869732E6170706C7945787465726E616C4D617070696E67732873293B7468';
wwv_flow_api.g_varchar2_table(177) := '69732E6F7074696F6E732E707574436F6D6D656E7428732C2866756E6374696F6E2874297B76617220653D6E2E637265617465436F6D6D656E744D6F64656C2874293B64656C65746520652E6368696C64732C6E2E757064617465436F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(178) := '64656C2865292C692E66696E6428222E636C6F736522292E747269676765722822636C69636B22292C6E2E726552656E646572436F6D6D656E7428652E6964292C6E2E736574427574746F6E537461746528612C21312C2131297D292C2866756E637469';
wwv_flow_api.g_varchar2_table(179) := '6F6E28297B6E2E736574427574746F6E537461746528612C21302C2131297D29297D2C64656C657465436F6D6D656E743A66756E6374696F6E2865297B766172206E3D746869732C613D7428652E63757272656E74546172676574292C693D612E706172';
wwv_flow_api.g_varchar2_table(180) := '656E747328222E636F6D6D656E7422292E666972737428292C6F3D742E657874656E64287B7D2C746869732E636F6D6D656E7473427949645B692E617474722822646174612D696422295D292C733D6F2E69642C723D6F2E706172656E743B746869732E';
wwv_flow_api.g_varchar2_table(181) := '736574427574746F6E537461746528612C21312C2130292C6F3D746869732E6170706C7945787465726E616C4D617070696E6773286F293B746869732E6F7074696F6E732E64656C657465436F6D6D656E74286F2C2866756E6374696F6E28297B6E2E72';
wwv_flow_api.g_varchar2_table(182) := '656D6F7665436F6D6D656E742873292C7226266E2E726552656E646572436F6D6D656E74416374696F6E4261722872292C6E2E736574427574746F6E537461746528612C21312C2131297D292C2866756E6374696F6E28297B6E2E736574427574746F6E';
wwv_flow_api.g_varchar2_table(183) := '537461746528612C21302C2131297D29297D2C68617368746167436C69636B65643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292E617474722822646174612D76616C756522293B746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(184) := '6E732E68617368746167436C69636B6564286E297D2C70696E67436C69636B65643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292E617474722822646174612D76616C756522293B746869732E6F7074696F';
wwv_flow_api.g_varchar2_table(185) := '6E732E70696E67436C69636B6564286E297D2C66696C65496E7075744368616E6765643A66756E6374696F6E28652C6E297B6E3D652E63757272656E745461726765742E66696C65733B76617220613D7428652E63757272656E74546172676574292E70';
wwv_flow_api.g_varchar2_table(186) := '6172656E747328222E636F6D6D656E74696E672D6669656C6422292E666972737428293B746869732E707265536176654174746163686D656E7473286E2C61297D2C7570766F7465436F6D6D656E743A66756E6374696F6E2865297B766172206E2C613D';
wwv_flow_api.g_varchar2_table(187) := '746869732C693D7428652E63757272656E74546172676574292E706172656E747328226C692E636F6D6D656E7422292E666972737428292E6461746128292E6D6F64656C2C6F3D692E7570766F7465436F756E743B6E3D692E757365724861735570766F';
wwv_flow_api.g_varchar2_table(188) := '7465643F6F2D313A6F2B312C692E757365724861735570766F7465643D21692E757365724861735570766F7465642C692E7570766F7465436F756E743D6E2C746869732E726552656E6465725570766F74657328692E6964293B76617220733D742E6578';
wwv_flow_api.g_varchar2_table(189) := '74656E64287B7D2C69293B733D746869732E6170706C7945787465726E616C4D617070696E67732873293B746869732E6F7074696F6E732E7570766F7465436F6D6D656E7428732C2866756E6374696F6E2874297B76617220653D612E63726561746543';
wwv_flow_api.g_varchar2_table(190) := '6F6D6D656E744D6F64656C2874293B612E757064617465436F6D6D656E744D6F64656C2865292C612E726552656E6465725570766F74657328652E6964297D292C2866756E6374696F6E28297B692E757365724861735570766F7465643D21692E757365';
wwv_flow_api.g_varchar2_table(191) := '724861735570766F7465642C692E7570766F7465436F756E743D6F2C612E726552656E6465725570766F74657328692E6964297D29297D2C746F67676C655265706C6965733A66756E6374696F6E2865297B766172206E3D7428652E63757272656E7454';
wwv_flow_api.g_varchar2_table(192) := '6172676574293B6E2E7369626C696E677328222E746F67676C61626C652D7265706C7922292E746F67676C65436C617373282276697369626C6522292C746869732E736574546F67676C65416C6C427574746F6E54657874286E2C2130297D2C7265706C';
wwv_flow_api.g_varchar2_table(193) := '79427574746F6E436C69636B65643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292C613D6E2E706172656E747328222E636F6D6D656E7422292E666972737428292E6368696C6472656E28292E6669727374';
wwv_flow_api.g_varchar2_table(194) := '28292C693D6E2E706172656E747328222E636F6D6D656E7422292E666972737428292E6461746128292E69642C6F3D74282223636F6D6D656E742D6C69737422292E66696E6428222E636F6D6D656E74696E672D6669656C6422293B6966286F2E6C656E';
wwv_flow_api.g_varchar2_table(195) := '67746826266F2E72656D6F766528292C6F2E66696E6428222E746578746172656122292E617474722822646174612D706172656E742229213D69297B6F3D746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E742869292C61';
wwv_flow_api.g_varchar2_table(196) := '2E66696E6428222E7772617070657222292E666972737428292E6166746572286F293B76617220733D6F2E66696E6428222E746578746172656122293B746869732E6D6F7665437572736F72546F456E642873292C746869732E656E73757265456C656D';
wwv_flow_api.g_varchar2_table(197) := '656E74537461797356697369626C65286F297D7D2C65646974427574746F6E436C69636B65643A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292E706172656E747328226C692E636F6D6D656E7422292E6669';
wwv_flow_api.g_varchar2_table(198) := '72737428292C613D6E2E6461746128292E6D6F64656C3B6E2E616464436C61737328226564697422293B76617220693D746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E7428612E706172656E742C612E6964293B6E2E66';
wwv_flow_api.g_varchar2_table(199) := '696E6428222E636F6D6D656E742D7772617070657222292E666972737428292E617070656E642869293B766172206F3D692E66696E6428222E746578746172656122293B6F2E617474722822646174612D636F6D6D656E74222C612E6964292C6F2E6170';
wwv_flow_api.g_varchar2_table(200) := '70656E6428746869732E676574466F726D6174746564436F6D6D656E74436F6E74656E7428612C213029292C746869732E6D6F7665437572736F72546F456E64286F292C746869732E656E73757265456C656D656E74537461797356697369626C652869';
wwv_flow_api.g_varchar2_table(201) := '297D2C73686F7744726F707061626C654F7665726C61793A66756E6374696F6E2874297B746869732E6F7074696F6E732E656E61626C654174746163686D656E7473262628746869732E24656C2E66696E6428222E64726F707061626C652D6F7665726C';
wwv_flow_api.g_varchar2_table(202) := '617922292E6373732822746F70222C746869732E24656C5B305D2E7363726F6C6C546F70292C746869732E24656C2E66696E6428222E64726F707061626C652D6F7665726C617922292E73686F7728292C746869732E24656C2E616464436C6173732822';
wwv_flow_api.g_varchar2_table(203) := '647261672D6F6E676F696E672229297D2C68616E646C6544726167456E7465723A66756E6374696F6E2865297B766172206E3D7428652E63757272656E74546172676574292E646174612822646E642D636F756E7422297C7C303B6E2B2B2C7428652E63';
wwv_flow_api.g_varchar2_table(204) := '757272656E74546172676574292E646174612822646E642D636F756E74222C6E292C7428652E63757272656E74546172676574292E616464436C6173732822647261672D6F76657222297D2C68616E646C65447261674C656176653A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(205) := '28652C6E297B76617220613D7428652E63757272656E74546172676574292E646174612822646E642D636F756E7422293B612D2D2C7428652E63757272656E74546172676574292E646174612822646E642D636F756E74222C61292C303D3D6126262874';
wwv_flow_api.g_varchar2_table(206) := '28652E63757272656E74546172676574292E72656D6F7665436C6173732822647261672D6F76657222292C6E26266E2829297D2C68616E646C65447261674C65617665466F724F7665726C61793A66756E6374696F6E2874297B76617220653D74686973';
wwv_flow_api.g_varchar2_table(207) := '3B746869732E68616E646C65447261674C6561766528742C2866756E6374696F6E28297B652E6869646544726F707061626C654F7665726C617928297D29297D2C68616E646C65447261674C65617665466F7244726F707061626C653A66756E6374696F';
wwv_flow_api.g_varchar2_table(208) := '6E2874297B746869732E68616E646C65447261674C656176652874297D2C68616E646C65447261674F766572466F724F7665726C61793A66756E6374696F6E2874297B742E73746F7050726F7061676174696F6E28292C742E70726576656E7444656661';
wwv_flow_api.g_varchar2_table(209) := '756C7428292C742E6F726967696E616C4576656E742E646174615472616E736665722E64726F704566666563743D22636F7079227D2C6869646544726F707061626C654F7665726C61793A66756E6374696F6E28297B746869732E24656C2E66696E6428';
wwv_flow_api.g_varchar2_table(210) := '222E64726F707061626C652D6F7665726C617922292E6869646528292C746869732E24656C2E72656D6F7665436C6173732822647261672D6F6E676F696E6722297D2C68616E646C6544726F703A66756E6374696F6E2865297B652E70726576656E7444';
wwv_flow_api.g_varchar2_table(211) := '656661756C7428292C7428652E746172676574292E747269676765722822647261676C6561766522292C746869732E6869646544726F707061626C654F7665726C617928292C746869732E707265536176654174746163686D656E747328652E6F726967';
wwv_flow_api.g_varchar2_table(212) := '696E616C4576656E742E646174615472616E736665722E66696C6573297D2C73746F7050726F7061676174696F6E3A66756E6374696F6E2874297B742E73746F7050726F7061676174696F6E28297D2C63726561746548544D4C3A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(213) := '297B76617220653D746869732E6372656174654D61696E436F6D6D656E74696E674669656C64456C656D656E7428293B746869732E24656C2E617070656E642865292C652E66696E6428222E636F6E74726F6C2D726F7722292E6869646528292C652E66';
wwv_flow_api.g_varchar2_table(214) := '696E6428222E636C6F736522292E6869646528292C746869732E6F7074696F6E732E656E61626C654E617669676174696F6E262628746869732E24656C2E617070656E6428746869732E6372656174654E617669676174696F6E456C656D656E74282929';
wwv_flow_api.g_varchar2_table(215) := '2C746869732E73686F77416374697665536F72742829293B766172206E3D746869732E6372656174655370696E6E657228293B746869732E24656C2E617070656E64286E293B76617220613D7428223C6469762F3E222C7B636C6173733A22646174612D';
wwv_flow_api.g_varchar2_table(216) := '636F6E7461696E6572222C22646174612D636F6E7461696E6572223A22636F6D6D656E7473227D293B746869732E24656C2E617070656E642861293B76617220693D7428223C6469762F3E222C7B636C6173733A226E6F2D636F6D6D656E7473206E6F2D';
wwv_flow_api.g_varchar2_table(217) := '64617461222C746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E6F436F6D6D656E747354657874297D292C6F3D7428223C692F3E222C7B636C6173733A2266612066612D636F6D6D656E';
wwv_flow_api.g_varchar2_table(218) := '74732066612D3278227D293B696628746869732E6F7074696F6E732E6E6F436F6D6D656E747349636F6E55524C2E6C656E6774682626286F2E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(219) := '2E6E6F436F6D6D656E747349636F6E55524C2B27222927292C6F2E616464436C6173732822696D6167652229292C692E70726570656E64287428223C62722F3E2229292E70726570656E64286F292C612E617070656E642869292C746869732E6F707469';
wwv_flow_api.g_varchar2_table(220) := '6F6E732E656E61626C654174746163686D656E7473297B76617220733D7428223C6469762F3E222C7B636C6173733A22646174612D636F6E7461696E6572222C22646174612D636F6E7461696E6572223A226174746163686D656E7473227D293B746869';
wwv_flow_api.g_varchar2_table(221) := '732E24656C2E617070656E642873293B76617220723D7428223C6469762F3E222C7B636C6173733A226E6F2D6174746163686D656E7473206E6F2D64617461222C746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869';
wwv_flow_api.g_varchar2_table(222) := '732E6F7074696F6E732E6E6F4174746163686D656E747354657874297D292C6C3D7428223C692F3E222C7B636C6173733A2266612066612D7061706572636C69702066612D3278227D293B746869732E6F7074696F6E732E6174746163686D656E744963';
wwv_flow_api.g_varchar2_table(223) := '6F6E55524C2E6C656E6774682626286C2E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927292C6C2E616464436C6173732822696D61';
wwv_flow_api.g_varchar2_table(224) := '67652229292C722E70726570656E64287428223C62722F3E2229292E70726570656E64286C292C732E617070656E642872293B76617220633D7428223C6469762F3E222C7B636C6173733A2264726F707061626C652D6F7665726C6179227D292C643D74';
wwv_flow_api.g_varchar2_table(225) := '28223C6469762F3E222C7B636C6173733A2264726F707061626C652D636F6E7461696E6572227D292C703D7428223C6469762F3E222C7B636C6173733A2264726F707061626C65227D292C6D3D7428223C692F3E222C7B636C6173733A2266612066612D';
wwv_flow_api.g_varchar2_table(226) := '7061706572636C69702066612D3478227D293B746869732E6F7074696F6E732E75706C6F616449636F6E55524C2E6C656E6774682626286D2E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(227) := '2E75706C6F616449636F6E55524C2B27222927292C6D2E616464436C6173732822696D6167652229293B76617220683D7428223C6469762F3E222C7B746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074';
wwv_flow_api.g_varchar2_table(228) := '696F6E732E6174746163686D656E7444726F7054657874297D293B702E617070656E64286D292C702E617070656E642868292C632E68746D6C28642E68746D6C287029292E6869646528292C746869732E24656C2E617070656E642863297D7D2C637265';
wwv_flow_api.g_varchar2_table(229) := '61746550726F66696C6550696374757265456C656D656E743A66756E6374696F6E28652C6E297B696628652976617220613D7428223C6469762F3E22292E637373287B226261636B67726F756E642D696D616765223A2275726C28222B652B2229227D29';
wwv_flow_api.g_varchar2_table(230) := '3B656C736520613D7428223C692F3E222C7B636C6173733A2266612066612D75736572227D293B72657475726E20612E616464436C617373282270726F66696C652D7069637475726522292C612E617474722822646174612D757365722D6964222C6E29';
wwv_flow_api.g_varchar2_table(231) := '2C746869732E6F7074696F6E732E726F756E6450726F66696C6550696374757265732626612E616464436C6173732822726F756E6422292C617D2C6372656174654D61696E436F6D6D656E74696E674669656C64456C656D656E743A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(232) := '28297B72657475726E20746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E7428766F696420302C766F696420302C2130297D2C637265617465436F6D6D656E74696E674669656C64456C656D656E743A66756E6374696F6E';
wwv_flow_api.g_varchar2_table(233) := '28652C6E2C61297B76617220692C6F2C732C723D746869732C6C3D7428223C6469762F3E222C7B636C6173733A22636F6D6D656E74696E672D6669656C64227D293B6126266C2E616464436C61737328226D61696E22292C6E3F28693D746869732E636F';
wwv_flow_api.g_varchar2_table(234) := '6D6D656E7473427949645B6E5D2E70726F66696C655069637475726555524C2C6F3D746869732E636F6D6D656E7473427949645B6E5D2E63726561746F722C733D746869732E636F6D6D656E7473427949645B6E5D2E6174746163686D656E7473293A28';
wwv_flow_api.g_varchar2_table(235) := '693D746869732E6F7074696F6E732E70726F66696C655069637475726555524C2C6F3D746869732E6F7074696F6E732E63726561746F722C733D5B5D293B76617220633D746869732E63726561746550726F66696C6550696374757265456C656D656E74';
wwv_flow_api.g_varchar2_table(236) := '28692C6F292C643D7428223C6469762F3E222C7B636C6173733A2274657874617265612D77726170706572227D292C703D7428223C6469762F3E222C7B636C6173733A22636F6E74726F6C2D726F77227D292C6D3D7428223C6469762F3E222C7B636C61';
wwv_flow_api.g_varchar2_table(237) := '73733A227465787461726561222C22646174612D706C616365686F6C646572223A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E7465787461726561506C616365686F6C64657254657874292C636F';
wwv_flow_api.g_varchar2_table(238) := '6E74656E746564697461626C653A21307D293B746869732E61646A7573745465787461726561486569676874286D2C2131293B76617220683D746869732E637265617465436C6F7365427574746F6E28293B682E616464436C6173732822696E6C696E65';
wwv_flow_api.g_varchar2_table(239) := '2D627574746F6E22293B76617220753D6E3F22757064617465223A2273656E64222C673D6E3F746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E7361766554657874293A746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(240) := '2E74657874466F726D617474657228746869732E6F7074696F6E732E73656E6454657874292C663D7428223C7370616E2F3E222C7B636C6173733A752B22207361766520686967686C696768742D6261636B67726F756E64222C746578743A677D293B69';
wwv_flow_api.g_varchar2_table(241) := '6628662E6461746128226F726967696E616C2D636F6E74656E74222C67292C702E617070656E642866292C6E2626746869732E6973416C6C6F776564546F44656C657465286E29297B76617220763D746869732E6F7074696F6E732E74657874466F726D';
wwv_flow_api.g_varchar2_table(242) := '617474657228746869732E6F7074696F6E732E64656C65746554657874292C433D7428223C7370616E2F3E222C7B636C6173733A2264656C65746520656E61626C6564222C746578743A767D292E63737328226261636B67726F756E642D636F6C6F7222';
wwv_flow_api.g_varchar2_table(243) := '2C746869732E6F7074696F6E732E64656C657465427574746F6E436F6C6F72293B432E6461746128226F726967696E616C2D636F6E74656E74222C76292C702E617070656E642843297D696628746869732E6F7074696F6E732E656E61626C6541747461';
wwv_flow_api.g_varchar2_table(244) := '63686D656E7473297B76617220623D7428223C7370616E2F3E222C7B636C6173733A22656E61626C65642075706C6F6164227D292C793D7428223C692F3E222C7B636C6173733A2266612066612D7061706572636C6970227D292C783D7428223C696E70';
wwv_flow_api.g_varchar2_table(245) := '75742F3E222C7B747970653A2266696C65222C6D756C7469706C653A226D756C7469706C65222C22646174612D726F6C65223A226E6F6E65227D293B746869732E6F7074696F6E732E75706C6F616449636F6E55524C2E6C656E677468262628792E6373';
wwv_flow_api.g_varchar2_table(246) := '7328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E75706C6F616449636F6E55524C2B27222927292C792E616464436C6173732822696D6167652229292C622E617070656E642879292E617070656E';
wwv_flow_api.g_varchar2_table(247) := '642878293B76617220773D622E636C6F6E6528293B772E6461746128226F726967696E616C2D636F6E74656E74222C772E6368696C6472656E2829292C702E617070656E642877292C612626642E617070656E6428622E636C6F6E6528292E616464436C';
wwv_flow_api.g_varchar2_table(248) := '6173732822696E6C696E652D627574746F6E2229293B76617220543D7428223C6469762F3E222C7B636C6173733A226174746163686D656E7473227D293B742873292E65616368282866756E6374696F6E28742C65297B766172206E3D722E6372656174';
wwv_flow_api.g_varchar2_table(249) := '654174746163686D656E74546167456C656D656E7428652C2130293B542E617070656E64286E297D29292C702E617070656E642854297D696628642E617070656E642868292E617070656E64286D292E617070656E642870292C6C2E617070656E642863';
wwv_flow_api.g_varchar2_table(250) := '292E617070656E642864292C65297B6D2E617474722822646174612D706172656E74222C65293B766172206B3D746869732E636F6D6D656E7473427949645B655D3B6966286B2E706172656E74297B6D2E68746D6C2822266E6273703B22293B76617220';
wwv_flow_api.g_varchar2_table(251) := '523D2240222B6B2E66756C6C6E616D652C413D746869732E637265617465546167456C656D656E7428522C227265706C792D746F222C6B2E63726561746F722C7B22646174612D757365722D6964223A6B2E63726561746F727D293B6D2E70726570656E';
wwv_flow_api.g_varchar2_table(252) := '642841297D7D72657475726E20746869732E6F7074696F6E732E656E61626C6550696E67696E672626286D2E74657874636F6D706C657465285B7B6D617463683A2F285E7C5C732940285B5E405D2A29242F692C696E6465783A322C7365617263683A66';
wwv_flow_api.g_varchar2_table(253) := '756E6374696F6E28742C65297B743D722E6E6F726D616C697A655370616365732874293B722E6F7074696F6E732E736561726368557365727328742C652C2866756E6374696F6E28297B65285B5D297D29297D2C74656D706C6174653A66756E6374696F';
wwv_flow_api.g_varchar2_table(254) := '6E2865297B766172206E3D7428223C6469762F3E22292C613D722E63726561746550726F66696C6550696374757265456C656D656E7428652E70726F66696C655F706963747572655F75726C292C693D7428223C6469762F3E222C7B636C6173733A2264';
wwv_flow_api.g_varchar2_table(255) := '657461696C73227D292C6F3D7428223C6469762F3E222C7B636C6173733A226E616D65227D292E68746D6C28652E66756C6C6E616D65292C733D7428223C6469762F3E222C7B636C6173733A22656D61696C227D292E68746D6C28652E656D61696C293B';
wwv_flow_api.g_varchar2_table(256) := '72657475726E20652E656D61696C3F692E617070656E64286F292E617070656E642873293A28692E616464436C61737328226E6F2D656D61696C22292C692E617070656E64286F29292C6E2E617070656E642861292E617070656E642869292C6E2E6874';
wwv_flow_api.g_varchar2_table(257) := '6D6C28297D2C7265706C6163653A66756E6374696F6E2874297B72657475726E2220222B722E637265617465546167456C656D656E74282240222B742E66756C6C6E616D652C2270696E67222C742E69642C7B22646174612D757365722D6964223A742E';
wwv_flow_api.g_varchar2_table(258) := '69647D295B305D2E6F7574657248544D4C2B2220227D7D5D2C7B617070656E64546F3A222E6A71756572792D636F6D6D656E7473222C64726F70646F776E436C6173734E616D653A2264726F70646F776E206175746F636F6D706C657465222C6D617843';
wwv_flow_api.g_varchar2_table(259) := '6F756E743A352C7269676874456467654F66667365743A302C6465626F756E63653A3235307D292C742E666E2E74657874636F6D706C6574652E44726F70646F776E2E70726F746F747970652E72656E6465723D66756E6374696F6E2865297B76617220';
wwv_flow_api.g_varchar2_table(260) := '6E3D746869732E5F6275696C64436F6E74656E74732865292C613D742E6D617028652C2866756E6374696F6E2874297B72657475726E20742E76616C75657D29293B696628652E6C656E677468297B76617220693D655B305D2E73747261746567793B69';
wwv_flow_api.g_varchar2_table(261) := '2E69643F746869732E24656C2E617474722822646174612D7374726174656779222C692E6964293A746869732E24656C2E72656D6F7665417474722822646174612D737472617465677922292C746869732E5F72656E6465724865616465722861292C74';
wwv_flow_api.g_varchar2_table(262) := '6869732E5F72656E646572466F6F7465722861292C6E262628746869732E5F72656E646572436F6E74656E7473286E292C746869732E5F666974546F426F74746F6D28292C746869732E5F666974546F526967687428292C746869732E5F616374697661';
wwv_flow_api.g_varchar2_table(263) := '7465496E64657865644974656D2829292C746869732E5F7365745363726F6C6C28297D656C736520746869732E6E6F526573756C74734D6573736167653F746869732E5F72656E6465724E6F526573756C74734D6573736167652861293A746869732E73';
wwv_flow_api.g_varchar2_table(264) := '686F776E2626746869732E6465616374697661746528293B766172206F3D7061727365496E7428746869732E24656C2E6373732822746F702229292B722E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F7028293B7468';
wwv_flow_api.g_varchar2_table(265) := '69732E24656C2E6373732822746F70222C6F293B76617220733D746869732E24656C2E63737328226C65667422293B746869732E24656C2E63737328226C656674222C30293B766172206C3D722E24656C2E776964746828292D746869732E24656C2E6F';
wwv_flow_api.g_varchar2_table(266) := '75746572576964746828292C633D4D6174682E6D696E286C2C7061727365496E74287329293B746869732E24656C2E63737328226C656674222C63297D2C742E666E2E74657874636F6D706C6574652E436F6E74656E744564697461626C652E70726F74';
wwv_flow_api.g_varchar2_table(267) := '6F747970652E5F736B69705365617263683D66756E6374696F6E2874297B73776974636828742E6B6579436F6465297B6361736520393A636173652031333A636173652031363A636173652031373A636173652033333A636173652033343A6361736520';
wwv_flow_api.g_varchar2_table(268) := '34303A636173652033383A636173652032373A72657475726E21307D696628742E6374726C4B65792973776974636828742E6B6579436F6465297B636173652037383A636173652038303A72657475726E21307D7D292C6C7D2C6372656174654E617669';
wwv_flow_api.g_varchar2_table(269) := '676174696F6E456C656D656E743A66756E6374696F6E28297B76617220653D7428223C756C2F3E222C7B636C6173733A226E617669676174696F6E227D292C6E3D7428223C6469762F3E222C7B636C6173733A226E617669676174696F6E2D7772617070';
wwv_flow_api.g_varchar2_table(270) := '6572227D293B652E617070656E64286E293B76617220613D7428223C6C692F3E222C7B746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E657765737454657874292C22646174612D736F';
wwv_flow_api.g_varchar2_table(271) := '72742D6B6579223A226E6577657374222C22646174612D636F6E7461696E65722D6E616D65223A22636F6D6D656E7473227D292C693D7428223C6C692F3E222C7B746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869';
wwv_flow_api.g_varchar2_table(272) := '732E6F7074696F6E732E6F6C6465737454657874292C22646174612D736F72742D6B6579223A226F6C64657374222C22646174612D636F6E7461696E65722D6E616D65223A22636F6D6D656E7473227D292C6F3D7428223C6C692F3E222C7B746578743A';
wwv_flow_api.g_varchar2_table(273) := '746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E706F70756C617254657874292C22646174612D736F72742D6B6579223A22706F70756C6172697479222C22646174612D636F6E7461696E65722D6E61';
wwv_flow_api.g_varchar2_table(274) := '6D65223A22636F6D6D656E7473227D292C733D7428223C6C692F3E222C7B746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6174746163686D656E747354657874292C22646174612D736F';
wwv_flow_api.g_varchar2_table(275) := '72742D6B6579223A226174746163686D656E7473222C22646174612D636F6E7461696E65722D6E616D65223A226174746163686D656E7473227D292C723D7428223C692F3E222C7B636C6173733A2266612066612D7061706572636C6970227D293B7468';
wwv_flow_api.g_varchar2_table(276) := '69732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E677468262628722E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E5552';
wwv_flow_api.g_varchar2_table(277) := '4C2B27222927292C722E616464436C6173732822696D6167652229292C732E70726570656E642872293B766172206C3D7428223C6469762F3E222C7B636C6173733A226E617669676174696F6E2D7772617070657220726573706F6E73697665227D292C';
wwv_flow_api.g_varchar2_table(278) := '633D7428223C756C2F3E222C7B636C6173733A2264726F70646F776E227D292C643D7428223C6C692F3E222C7B636C6173733A227469746C65227D292C703D7428223C6865616465722F3E22293B72657475726E20642E617070656E642870292C6C2E61';
wwv_flow_api.g_varchar2_table(279) := '7070656E642864292C6C2E617070656E642863292C652E617070656E64286C292C6E2E617070656E642861292E617070656E642869292C632E617070656E6428612E636C6F6E652829292E617070656E6428692E636C6F6E652829292C28746869732E6F';
wwv_flow_api.g_varchar2_table(280) := '7074696F6E732E656E61626C655265706C79696E677C7C746869732E6F7074696F6E732E656E61626C655570766F74696E67292626286E2E617070656E64286F292C632E617070656E64286F2E636C6F6E65282929292C746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(281) := '656E61626C654174746163686D656E74732626286E2E617070656E642873292C6C2E617070656E6428732E636C6F6E65282929292C746869732E6F7074696F6E732E666F726365526573706F6E736976652626746869732E666F726365526573706F6E73';
wwv_flow_api.g_varchar2_table(282) := '69766528292C657D2C6372656174655370696E6E65723A66756E6374696F6E2865297B766172206E3D7428223C6469762F3E222C7B636C6173733A227370696E6E6572227D293B6526266E2E616464436C6173732822696E6C696E6522293B7661722061';
wwv_flow_api.g_varchar2_table(283) := '3D7428223C692F3E222C7B636C6173733A2266612066612D7370696E6E65722066612D7370696E227D293B72657475726E20746869732E6F7074696F6E732E7370696E6E657249636F6E55524C2E6C656E677468262628612E63737328226261636B6772';
wwv_flow_api.g_varchar2_table(284) := '6F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E7370696E6E657249636F6E55524C2B27222927292C612E616464436C6173732822696D6167652229292C6E2E68746D6C2861292C6E7D2C637265617465436C6F736542';
wwv_flow_api.g_varchar2_table(285) := '7574746F6E3A66756E6374696F6E2865297B766172206E3D7428223C7370616E2F3E222C7B636C6173733A657C7C22636C6F7365227D292C613D7428223C692F3E222C7B636C6173733A2266612066612D74696D6573227D293B72657475726E20746869';
wwv_flow_api.g_varchar2_table(286) := '732E6F7074696F6E732E636C6F736549636F6E55524C2E6C656E677468262628612E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E636C6F736549636F6E55524C2B27222927292C612E61';
wwv_flow_api.g_varchar2_table(287) := '6464436C6173732822696D6167652229292C6E2E68746D6C2861292C6E7D2C637265617465436F6D6D656E74456C656D656E743A66756E6374696F6E2865297B766172206E3D7428223C6C692F3E222C7B22646174612D6964223A652E69642C636C6173';
wwv_flow_api.g_varchar2_table(288) := '733A22636F6D6D656E74227D292E6461746128226D6F64656C222C65293B652E63726561746564427943757272656E745573657226266E2E616464436C617373282262792D63757272656E742D7573657222292C652E63726561746564427941646D696E';
wwv_flow_api.g_varchar2_table(289) := '26266E2E616464436C617373282262792D61646D696E22293B76617220613D7428223C756C2F3E222C7B636C6173733A226368696C642D636F6D6D656E7473227D292C693D746869732E637265617465436F6D6D656E7457726170706572456C656D656E';
wwv_flow_api.g_varchar2_table(290) := '742865293B72657475726E206E2E617070656E642869292C6E2E617070656E642861292C6E7D2C637265617465436F6D6D656E7457726170706572456C656D656E743A66756E6374696F6E2865297B766172206E3D746869732C613D7428223C6469762F';
wwv_flow_api.g_varchar2_table(291) := '3E222C7B636C6173733A22636F6D6D656E742D77726170706572227D292C693D746869732E63726561746550726F66696C6550696374757265456C656D656E7428652E70726F66696C655069637475726555524C2C652E63726561746F72292C6F3D7428';
wwv_flow_api.g_varchar2_table(292) := '223C74696D652F3E222C7B746578743A746869732E6F7074696F6E732E74696D65466F726D617474657228652E63726561746564292C22646174612D6F726967696E616C223A652E637265617465647D292C733D7428223C6469762F3E222C7B636C6173';
wwv_flow_api.g_varchar2_table(293) := '733A22636F6D6D656E742D686561646572227D292C723D7428223C7370616E2F3E222C7B636C6173733A226E616D65222C22646174612D757365722D6964223A652E63726561746F722C746578743A652E63726561746564427943757272656E74557365';
wwv_flow_api.g_varchar2_table(294) := '723F746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E796F7554657874293A652E66756C6C6E616D657D293B696628732E617070656E642872292C652E63726561746564427941646D696E2626722E61';
wwv_flow_api.g_varchar2_table(295) := '6464436C6173732822686967686C696768742D666F6E742D626F6C6422292C652E706172656E74297B766172206C3D746869732E636F6D6D656E7473427949645B652E706172656E745D3B6966286C2E706172656E74297B76617220633D7428223C7370';
wwv_flow_api.g_varchar2_table(296) := '616E2F3E222C7B636C6173733A227265706C792D746F222C746578743A6C2E66756C6C6E616D652C22646174612D757365722D6964223A6C2E63726561746F727D292C643D7428223C692F3E222C7B636C6173733A2266612066612D7368617265227D29';
wwv_flow_api.g_varchar2_table(297) := '3B746869732E6F7074696F6E732E7265706C7949636F6E55524C2E6C656E677468262628642E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E7265706C7949636F6E55524C2B2722292729';
wwv_flow_api.g_varchar2_table(298) := '2C642E616464436C6173732822696D6167652229292C632E70726570656E642864292C732E617070656E642863297D7D696628652E69734E6577297B76617220703D7428223C7370616E2F3E222C7B636C6173733A226E657720686967686C696768742D';
wwv_flow_api.g_varchar2_table(299) := '6261636B67726F756E64222C746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E657754657874297D293B732E617070656E642870297D766172206D3D7428223C6469762F3E222C7B636C';
wwv_flow_api.g_varchar2_table(300) := '6173733A2277726170706572227D292C683D7428223C6469762F3E222C7B636C6173733A22636F6E74656E74227D293B696628682E68746D6C28746869732E676574466F726D6174746564436F6D6D656E74436F6E74656E74286529292C652E6D6F6469';
wwv_flow_api.g_varchar2_table(301) := '666965642626652E6D6F646966696564213D652E63726561746564297B76617220753D746869732E6F7074696F6E732E74696D65466F726D617474657228652E6D6F646966696564292C673D7428223C74696D652F3E222C7B636C6173733A2265646974';
wwv_flow_api.g_varchar2_table(302) := '6564222C746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E65646974656454657874292B2220222B752C22646174612D6F726967696E616C223A652E6D6F6469666965647D293B682E6170';
wwv_flow_api.g_varchar2_table(303) := '70656E642867297D76617220663D7428223C6469762F3E222C7B636C6173733A226174746163686D656E7473227D292C763D7428223C6469762F3E222C7B636C6173733A227072657669657773227D292C433D7428223C6469762F3E222C7B636C617373';
wwv_flow_api.g_varchar2_table(304) := '3A2274616773227D293B662E617070656E642876292E617070656E642843292C746869732E6F7074696F6E732E656E61626C654174746163686D656E74732626652E6861734174746163686D656E7473282926267428652E6174746163686D656E747329';
wwv_flow_api.g_varchar2_table(305) := '2E65616368282866756E6374696F6E28652C61297B76617220693D766F696420303B696628612E6D696D655F74797065297B766172206F3D612E6D696D655F747970652E73706C697428222F22293B323D3D6F2E6C656E6774682626286F5B315D2C693D';
wwv_flow_api.g_varchar2_table(306) := '6F5B305D297D69662822696D616765223D3D697C7C22766964656F223D3D69297B76617220733D7428223C6469762F3E22292C723D7428223C612F3E222C7B636C6173733A2270726576696577222C687265663A612E66696C652C7461726765743A225F';
wwv_flow_api.g_varchar2_table(307) := '626C616E6B227D293B696628732E68746D6C2872292C22696D616765223D3D69297B766172206C3D7428223C696D672F3E222C7B7372633A612E66696C657D293B722E68746D6C286C297D656C73657B76617220633D7428223C766964656F2F3E222C7B';
wwv_flow_api.g_varchar2_table(308) := '7372633A612E66696C652C747970653A612E6D696D655F747970652C636F6E74726F6C733A22636F6E74726F6C73227D293B722E68746D6C2863297D762E617070656E642873297D76617220643D6E2E6372656174654174746163686D656E7454616745';
wwv_flow_api.g_varchar2_table(309) := '6C656D656E7428612C2131293B432E617070656E642864297D29293B76617220623D7428223C7370616E2F3E222C7B636C6173733A22616374696F6E73227D292C793D7428223C7370616E2F3E222C7B636C6173733A22736570617261746F72222C7465';
wwv_flow_api.g_varchar2_table(310) := '78743A22C2B7227D292C783D7428223C627574746F6E2F3E222C7B636C6173733A22616374696F6E207265706C79222C747970653A22627574746F6E222C746578743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F';
wwv_flow_api.g_varchar2_table(311) := '7074696F6E732E7265706C7954657874297D292C773D7428223C692F3E222C7B636C6173733A2266612066612D7468756D62732D7570227D293B746869732E6F7074696F6E732E7570766F746549636F6E55524C2E6C656E677468262628772E63737328';
wwv_flow_api.g_varchar2_table(312) := '226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E7570766F746549636F6E55524C2B27222927292C772E616464436C6173732822696D6167652229293B76617220543D746869732E6372656174655570';
wwv_flow_api.g_varchar2_table(313) := '766F7465456C656D656E742865293B696628746869732E6F7074696F6E732E656E61626C655265706C79696E672626622E617070656E642878292C746869732E6F7074696F6E732E656E61626C655570766F74696E672626622E617070656E642854292C';
wwv_flow_api.g_varchar2_table(314) := '652E63726561746564427943757272656E74557365727C7C746869732E6F7074696F6E732E63757272656E7455736572497341646D696E297B766172206B3D7428223C627574746F6E2F3E222C7B636C6173733A22616374696F6E2065646974222C7465';
wwv_flow_api.g_varchar2_table(315) := '78743A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6564697454657874297D293B622E617070656E64286B297D72657475726E20622E6368696C6472656E28292E65616368282866756E6374696F';
wwv_flow_api.g_varchar2_table(316) := '6E28652C6E297B74286E292E697328223A6C6173742D6368696C6422297C7C74286E292E616674657228792E636C6F6E652829297D29292C6D2E617070656E642868292C6D2E617070656E642866292C6D2E617070656E642862292C612E617070656E64';
wwv_flow_api.g_varchar2_table(317) := '2869292E617070656E64286F292E617070656E642873292E617070656E64286D292C617D2C6372656174655570766F7465456C656D656E743A66756E6374696F6E2865297B766172206E3D7428223C692F3E222C7B636C6173733A2266612066612D7468';
wwv_flow_api.g_varchar2_table(318) := '756D62732D7570227D293B72657475726E20746869732E6F7074696F6E732E7570766F746549636F6E55524C2E6C656E6774682626286E2E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869732E6F7074696F6E732E';
wwv_flow_api.g_varchar2_table(319) := '7570766F746549636F6E55524C2B27222927292C6E2E616464436C6173732822696D6167652229292C7428223C627574746F6E2F3E222C7B636C6173733A22616374696F6E207570766F7465222B28652E757365724861735570766F7465643F22206869';
wwv_flow_api.g_varchar2_table(320) := '67686C696768742D666F6E74223A2222297D292E617070656E64287428223C7370616E2F3E222C7B746578743A652E7570766F7465436F756E742C636C6173733A227570766F74652D636F756E74227D29292E617070656E64286E297D2C637265617465';
wwv_flow_api.g_varchar2_table(321) := '546167456C656D656E743A66756E6374696F6E28652C6E2C612C69297B766172206F3D7428223C696E7075742F3E222C7B636C6173733A22746167222C747970653A22627574746F6E222C22646174612D726F6C65223A226E6F6E65227D293B72657475';
wwv_flow_api.g_varchar2_table(322) := '726E206E26266F2E616464436C617373286E292C6F2E76616C2865292C6F2E617474722822646174612D76616C7565222C61292C6926266F2E617474722869292C6F7D2C6372656174654174746163686D656E74546167456C656D656E743A66756E6374';
wwv_flow_api.g_varchar2_table(323) := '696F6E28652C6E297B76617220613D7428223C612F3E222C7B636C6173733A22746167206174746163686D656E74222C7461726765743A225F626C616E6B227D293B6E7C7C612E61747472282268726566222C652E66696C65292C612E64617461287B69';
wwv_flow_api.g_varchar2_table(324) := '643A652E69642C6D696D655F747970653A652E6D696D655F747970652C66696C653A652E66696C657D293B76617220693D22223B696628652E66696C6520696E7374616E63656F662046696C6529693D652E66696C652E6E616D653B656C73657B766172';
wwv_flow_api.g_varchar2_table(325) := '206F3D652E66696C652E73706C697428222F22293B693D28693D6F5B6F2E6C656E6774682D315D292E73706C697428223F22295B305D2C693D6465636F6465555249436F6D706F6E656E742869297D76617220733D7428223C692F3E222C7B636C617373';
wwv_flow_api.g_varchar2_table(326) := '3A2266612066612D7061706572636C6970227D293B696628746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E677468262628732E63737328226261636B67726F756E642D696D616765222C2775726C2822272B746869';
wwv_flow_api.g_varchar2_table(327) := '732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927292C732E616464436C6173732822696D6167652229292C612E617070656E6428732C69292C6E297B612E616464436C617373282264656C657461626C6522293B76617220';
wwv_flow_api.g_varchar2_table(328) := '723D746869732E637265617465436C6F7365427574746F6E282264656C65746522293B612E617070656E642872297D72657475726E20617D2C726552656E646572436F6D6D656E743A66756E6374696F6E2865297B766172206E3D746869732E636F6D6D';
wwv_flow_api.g_varchar2_table(329) := '656E7473427949645B655D2C613D746869732E24656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B6E2E69642B27225D27292C693D746869733B612E65616368282866756E6374696F6E28652C61297B766172206F3D692E63';
wwv_flow_api.g_varchar2_table(330) := '7265617465436F6D6D656E7457726170706572456C656D656E74286E293B742861292E66696E6428222E636F6D6D656E742D7772617070657222292E666972737428292E7265706C61636557697468286F297D29297D2C726552656E646572436F6D6D65';
wwv_flow_api.g_varchar2_table(331) := '6E74416374696F6E4261723A66756E6374696F6E2865297B766172206E3D746869732E636F6D6D656E7473427949645B655D2C613D746869732E24656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B6E2E69642B27225D2729';
wwv_flow_api.g_varchar2_table(332) := '2C693D746869733B612E65616368282866756E6374696F6E28652C61297B766172206F3D692E637265617465436F6D6D656E7457726170706572456C656D656E74286E293B742861292E66696E6428222E616374696F6E7322292E666972737428292E72';
wwv_flow_api.g_varchar2_table(333) := '65706C61636557697468286F2E66696E6428222E616374696F6E732229297D29297D2C726552656E6465725570766F7465733A66756E6374696F6E2865297B766172206E3D746869732E636F6D6D656E7473427949645B655D2C613D746869732E24656C';
wwv_flow_api.g_varchar2_table(334) := '2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B6E2E69642B27225D27292C693D746869733B612E65616368282866756E6374696F6E28652C61297B766172206F3D692E6372656174655570766F7465456C656D656E74286E293B';
wwv_flow_api.g_varchar2_table(335) := '742861292E66696E6428222E7570766F746522292E666972737428292E7265706C61636557697468286F297D29297D2C6372656174654373734465636C61726174696F6E733A66756E6374696F6E28297B74282268656164207374796C652E6A71756572';
wwv_flow_api.g_varchar2_table(336) := '792D636F6D6D656E74732D63737322292E72656D6F766528292C746869732E63726561746543737328222E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C692E6163746976653A6166746572207B6261636B67726F756E64';
wwv_flow_api.g_varchar2_table(337) := '3A20222B746869732E6F7074696F6E732E686967686C69676874436F6C6F722B222021696D706F7274616E743B222C4E614E292C746869732E63726561746543737328222E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E2075';
wwv_flow_api.g_varchar2_table(338) := '6C2E64726F70646F776E206C692E616374697665207B6261636B67726F756E643A20222B746869732E6F7074696F6E732E686967686C69676874436F6C6F722B222021696D706F7274616E743B222C4E614E292C746869732E6372656174654373732822';
wwv_flow_api.g_varchar2_table(339) := '2E6A71756572792D636F6D6D656E7473202E686967686C696768742D6261636B67726F756E64207B6261636B67726F756E643A20222B746869732E6F7074696F6E732E686967686C69676874436F6C6F722B222021696D706F7274616E743B222C4E614E';
wwv_flow_api.g_varchar2_table(340) := '292C746869732E63726561746543737328222E6A71756572792D636F6D6D656E7473202E686967686C696768742D666F6E74207B636F6C6F723A20222B746869732E6F7074696F6E732E686967686C69676874436F6C6F722B222021696D706F7274616E';
wwv_flow_api.g_varchar2_table(341) := '743B7D22292C746869732E63726561746543737328222E6A71756572792D636F6D6D656E7473202E686967686C696768742D666F6E742D626F6C64207B636F6C6F723A20222B746869732E6F7074696F6E732E686967686C69676874436F6C6F722B2220';
wwv_flow_api.g_varchar2_table(342) := '21696D706F7274616E743B666F6E742D7765696768743A20626F6C643B7D22297D2C6372656174654373733A66756E6374696F6E2865297B766172206E3D7428223C7374796C652F3E222C7B747970653A22746578742F637373222C636C6173733A226A';
wwv_flow_api.g_varchar2_table(343) := '71756572792D636F6D6D656E74732D637373222C746578743A657D293B7428226865616422292E617070656E64286E297D2C676574436F6D6D656E74733A66756E6374696F6E28297B76617220743D746869733B72657475726E204F626A6563742E6B65';
wwv_flow_api.g_varchar2_table(344) := '797328746869732E636F6D6D656E747342794964292E6D6170282866756E6374696F6E2865297B72657475726E20742E636F6D6D656E7473427949645B655D7D29297D2C6765744368696C64436F6D6D656E74733A66756E6374696F6E2874297B726574';
wwv_flow_api.g_varchar2_table(345) := '75726E20746869732E676574436F6D6D656E747328292E66696C746572282866756E6374696F6E2865297B72657475726E20652E706172656E743D3D747D29297D2C6765744174746163686D656E74733A66756E6374696F6E28297B72657475726E2074';
wwv_flow_api.g_varchar2_table(346) := '6869732E676574436F6D6D656E747328292E66696C746572282866756E6374696F6E2874297B72657475726E20742E6861734174746163686D656E747328297D29297D2C6765744F757465726D6F7374506172656E743A66756E6374696F6E2874297B76';
wwv_flow_api.g_varchar2_table(347) := '617220653D743B646F7B766172206E3D746869732E636F6D6D656E7473427949645B655D3B653D6E2E706172656E747D7768696C65286E756C6C213D6E2E706172656E74293B72657475726E206E7D2C637265617465436F6D6D656E744A534F4E3A6675';
wwv_flow_api.g_varchar2_table(348) := '6E6374696F6E2874297B76617220653D742E66696E6428222E746578746172656122292C6E3D286E65772044617465292E746F49534F537472696E6728293B72657475726E7B69643A2263222B28746869732E676574436F6D6D656E747328292E6C656E';
wwv_flow_api.g_varchar2_table(349) := '6774682B31292C706172656E743A652E617474722822646174612D706172656E7422297C7C6E756C6C2C637265617465643A6E2C6D6F6469666965643A6E2C636F6E74656E743A746869732E6765745465787461726561436F6E74656E742865292C7069';
wwv_flow_api.g_varchar2_table(350) := '6E67733A746869732E67657450696E67732865292C66756C6C6E616D653A746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E796F7554657874292C70726F66696C655069637475726555524C3A746869';
wwv_flow_api.g_varchar2_table(351) := '732E6F7074696F6E732E70726F66696C655069637475726555524C2C63726561746564427943757272656E74557365723A21302C7570766F7465436F756E743A302C757365724861735570766F7465643A21312C6174746163686D656E74733A74686973';
wwv_flow_api.g_varchar2_table(352) := '2E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C642874297D7D2C6973416C6C6F776564546F44656C6574653A66756E6374696F6E2865297B696628746869732E6F7074696F6E732E656E61626C6544656C6574696E67';
wwv_flow_api.g_varchar2_table(353) := '297B766172206E3D21303B72657475726E20746869732E6F7074696F6E732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965737C7C7428746869732E676574436F6D6D656E74732829292E65616368282866756E6374696F';
wwv_flow_api.g_varchar2_table(354) := '6E28742C61297B612E706172656E743D3D652626286E3D2131297D29292C6E7D72657475726E21317D2C736574546F67676C65416C6C427574746F6E546578743A66756E6374696F6E28742C65297B766172206E3D746869732C613D742E66696E642822';
wwv_flow_api.g_varchar2_table(355) := '7370616E2E7465787422292C693D742E66696E6428222E636172657422292C6F3D66756E6374696F6E28297B76617220653D6E2E6F7074696F6E732E74657874466F726D6174746572286E2E6F7074696F6E732E76696577416C6C5265706C6965735465';
wwv_flow_api.g_varchar2_table(356) := '7874292C693D742E7369626C696E677328222E636F6D6D656E7422292E6E6F7428222E68696464656E22292E6C656E6774683B653D652E7265706C61636528225F5F7265706C79436F756E745F5F222C69292C612E746578742865297D2C733D74686973';
wwv_flow_api.g_varchar2_table(357) := '2E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E686964655265706C69657354657874293B653F28612E7465787428293D3D733F6F28293A612E746578742873292C692E746F67676C65436C6173732822757022';
wwv_flow_api.g_varchar2_table(358) := '29293A612E746578742829213D7326266F28297D2C736574427574746F6E53746174653A66756E6374696F6E28742C652C6E297B742E746F67676C65436C6173732822656E61626C6564222C65292C6E3F742E68746D6C28746869732E63726561746553';
wwv_flow_api.g_varchar2_table(359) := '70696E6E657228213029293A742E68746D6C28742E6461746128226F726967696E616C2D636F6E74656E742229297D2C61646A75737454657874617265614865696768743A66756E6374696F6E28652C6E297B653D742865293B76617220612C693D313D';
wwv_flow_api.g_varchar2_table(360) := '3D6E3F746869732E6F7074696F6E732E7465787461726561526F77734F6E466F6375733A746869732E6F7074696F6E732E7465787461726561526F77733B646F7B613D766F696420302C613D322E322B312E34352A28692D31292C652E63737328226865';
wwv_flow_api.g_varchar2_table(361) := '69676874222C612B22656D22292C692B2B3B766172206F3D655B305D2E7363726F6C6C4865696768743E652E6F7574657248656967687428292C733D30213D746869732E6F7074696F6E732E74657874617265614D6178526F77732626693E746869732E';
wwv_flow_api.g_varchar2_table(362) := '6F7074696F6E732E74657874617265614D6178526F77737D7768696C65286F26262173297D2C636C65617254657874617265613A66756E6374696F6E2874297B742E656D70747928292E747269676765722822696E70757422297D2C6765745465787461';
wwv_flow_api.g_varchar2_table(363) := '726561436F6E74656E743A66756E6374696F6E28652C6E297B76617220613D652E636C6F6E6528293B612E66696E6428222E7265706C792D746F2E74616722292E72656D6F766528292C612E66696E6428222E7461672E6861736874616722292E726570';
wwv_flow_api.g_varchar2_table(364) := '6C61636557697468282866756E6374696F6E28297B72657475726E206E3F742874686973292E76616C28293A2223222B742874686973292E617474722822646174612D76616C756522297D29292C612E66696E6428222E7461672E70696E6722292E7265';
wwv_flow_api.g_varchar2_table(365) := '706C61636557697468282866756E6374696F6E28297B72657475726E206E3F742874686973292E76616C28293A2240222B742874686973292E617474722822646174612D76616C756522297D29293B76617220693D7428223C7072652F3E22292E68746D';
wwv_flow_api.g_varchar2_table(366) := '6C28612E68746D6C2829293B692E66696E6428226469762C20702C20627222292E7265706C61636557697468282866756E6374696F6E28297B72657475726E225C6E222B746869732E696E6E657248544D4C7D29293B766172206F3D692E746578742829';
wwv_flow_api.g_varchar2_table(367) := '2E7265706C616365282F5E5C732B2F672C2222293B72657475726E206F3D746869732E6E6F726D616C697A65537061636573286F297D2C676574466F726D6174746564436F6D6D656E74436F6E74656E743A66756E6374696F6E28742C65297B76617220';
wwv_flow_api.g_varchar2_table(368) := '6E3D746869732E65736361706528742E636F6E74656E74293B72657475726E206E3D746869732E6C696E6B696679286E292C6E3D746869732E686967686C696768745461677328742C6E292C652626286E3D6E2E7265706C616365282F283F3A5C6E292F';
wwv_flow_api.g_varchar2_table(369) := '672C223C62723E2229292C6E7D2C67657450696E67733A66756E6374696F6E2865297B766172206E3D7B7D3B72657475726E20652E66696E6428222E70696E6722292E65616368282866756E6374696F6E28652C61297B76617220693D7061727365496E';
wwv_flow_api.g_varchar2_table(370) := '7428742861292E617474722822646174612D76616C75652229292C6F3D742861292E76616C28293B6E5B695D3D6F2E736C6963652831297D29292C6E7D2C6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C643A66756E63';
wwv_flow_api.g_varchar2_table(371) := '74696F6E2865297B72657475726E20652E66696E6428222E6174746163686D656E7473202E6174746163686D656E7422292E6D6170282866756E6374696F6E28297B72657475726E20742874686973292E6461746128297D29292E746F41727261792829';
wwv_flow_api.g_varchar2_table(372) := '7D2C6D6F7665437572736F72546F456E643A66756E6374696F6E2865297B696628653D742865295B305D2C742865292E747269676765722822696E70757422292C742865292E7363726F6C6C546F7028652E7363726F6C6C486569676874292C766F6964';
wwv_flow_api.g_varchar2_table(373) := '2030213D3D77696E646F772E67657453656C656374696F6E2626766F69642030213D3D646F63756D656E742E63726561746552616E6765297B766172206E3D646F63756D656E742E63726561746552616E676528293B6E2E73656C6563744E6F6465436F';
wwv_flow_api.g_varchar2_table(374) := '6E74656E74732865292C6E2E636F6C6C61707365282131293B76617220613D77696E646F772E67657453656C656374696F6E28293B612E72656D6F7665416C6C52616E67657328292C612E61646452616E6765286E297D656C736520696628766F696420';
wwv_flow_api.g_varchar2_table(375) := '30213D3D646F63756D656E742E626F64792E6372656174655465787452616E6765297B76617220693D646F63756D656E742E626F64792E6372656174655465787452616E676528293B692E6D6F7665546F456C656D656E74546578742865292C692E636F';
wwv_flow_api.g_varchar2_table(376) := '6C6C61707365282131292C692E73656C65637428297D652E666F63757328297D2C656E73757265456C656D656E74537461797356697369626C653A66756E6374696F6E2874297B76617220653D742E706F736974696F6E28292E746F702C6E3D742E706F';
wwv_flow_api.g_varchar2_table(377) := '736974696F6E28292E746F702B742E6F7574657248656967687428292D746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E6F7574657248656967687428293B746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E6572';
wwv_flow_api.g_varchar2_table(378) := '2E7363726F6C6C546F7028293E653F746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F702865293A746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F7028293C6E26';
wwv_flow_api.g_varchar2_table(379) := '26746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F70286E297D2C6573636170653A66756E6374696F6E2865297B72657475726E207428223C7072652F3E22292E7465787428746869732E6E6F726D616C697A';
wwv_flow_api.g_varchar2_table(380) := '65537061636573286529292E68746D6C28297D2C6E6F726D616C697A655370616365733A66756E6374696F6E2874297B72657475726E20742E7265706C616365286E6577205265674578702822C2A0222C226722292C222022297D2C61667465723A6675';
wwv_flow_api.g_varchar2_table(381) := '6E6374696F6E28742C65297B766172206E3D746869733B72657475726E2066756E6374696F6E28297B696628303D3D2D2D742972657475726E20652E6170706C79286E2C617267756D656E7473297D7D2C686967686C69676874546167733A66756E6374';
wwv_flow_api.g_varchar2_table(382) := '696F6E28742C65297B72657475726E20746869732E6F7074696F6E732E656E61626C654861736874616773262628653D746869732E686967686C69676874486173687461677328742C6529292C746869732E6F7074696F6E732E656E61626C6550696E67';
wwv_flow_api.g_varchar2_table(383) := '696E67262628653D746869732E686967686C6967687450696E677328742C6529292C657D2C686967686C6967687448617368746167733A66756E6374696F6E28742C65297B766172206E3D746869733B6966282D31213D652E696E6465784F6628222322';
wwv_flow_api.g_varchar2_table(384) := '29297B653D652E7265706C616365282F285E7C5C732923285B612D7A5C75303043302D5C75303046465C642D5F5D2B292F67696D2C2866756E6374696F6E28742C652C61297B72657475726E20652B28693D612C28693D6E2E637265617465546167456C';
wwv_flow_api.g_varchar2_table(385) := '656D656E74282223222B692C2268617368746167222C6929295B305D2E6F7574657248544D4C293B76617220697D29297D72657475726E20657D2C686967686C6967687450696E67733A66756E6374696F6E28652C6E297B76617220613D746869733B69';
wwv_flow_api.g_varchar2_table(386) := '66282D31213D6E2E696E6465784F662822402229297B74284F626A6563742E6B65797328652E70696E677329292E65616368282866756E6374696F6E28742C69297B766172206F3D2240222B652E70696E67735B695D3B6E3D6E2E7265706C6163652822';
wwv_flow_api.g_varchar2_table(387) := '40222B692C66756E6374696F6E28742C65297B72657475726E20612E637265617465546167456C656D656E7428742C2270696E67222C652C7B22646174612D757365722D6964223A657D295B305D2E6F7574657248544D4C7D286F2C6929297D29297D72';
wwv_flow_api.g_varchar2_table(388) := '657475726E206E7D2C6C696E6B6966793A66756E6374696F6E2874297B76617220652C6E2C612C693B6966286E3D2F285C622868747470733F7C6674707C66696C65293A5C2F5C2F5B2D412D5AC384C396C385302D392B2640235C2F253F3D7E5F7C213A';
wwv_flow_api.g_varchar2_table(389) := '2C2E3B7B7D5D2A5B2D412D5AC384C396C385302D392B2640235C2F253D7E5F7C7B7D5D292F67696D2C613D2F285E7C5B5E5C2F665D29287777775C2E5B2D412D5AC384C396C385302D392B2640235C2F253F3D7E5F7C213A2C2E3B7B7D5D2A5B2D412D5A';
wwv_flow_api.g_varchar2_table(390) := 'C384C396C385302D392B2640235C2F253D7E5F7C7B7D5D292F67696D2C693D2F28285B412D5AC384C396C385302D395C2D5C5F5C2E5D292B405B412D5AC384C396C3855C5F5D2B3F285C2E5B412D5AC384C396C3855D7B322C367D292B292F67696D2C65';
wwv_flow_api.g_varchar2_table(391) := '3D28653D28653D742E7265706C616365286E2C273C6120687265663D22243122207461726765743D225F626C616E6B223E24313C2F613E2729292E7265706C61636528612C2724313C6120687265663D2268747470733A2F2F243222207461726765743D';
wwv_flow_api.g_varchar2_table(392) := '225F626C616E6B223E24323C2F613E2729292E7265706C61636528692C273C6120687265663D226D61696C746F3A243122207461726765743D225F626C616E6B223E24313C2F613E27292C28742E6D61746368282F3C6120687265662F67297C7C5B5D29';
wwv_flow_api.g_varchar2_table(393) := '2E6C656E6774683E30297B666F7228766172206F3D742E73706C6974282F283C5C2F613E292F67292C733D303B733C6F2E6C656E6774683B732B2B296E756C6C3D3D6F5B735D2E6D61746368282F3C6120687265662F67292626286F5B735D3D6F5B735D';
wwv_flow_api.g_varchar2_table(394) := '2E7265706C616365286E2C273C6120687265663D22243122207461726765743D225F626C616E6B223E24313C2F613E27292E7265706C61636528612C2724313C6120687265663D2268747470733A2F2F243222207461726765743D225F626C616E6B223E';
wwv_flow_api.g_varchar2_table(395) := '24323C2F613E27292E7265706C61636528692C273C6120687265663D226D61696C746F3A243122207461726765743D225F626C616E6B223E24313C2F613E2729293B72657475726E206F2E6A6F696E282222297D72657475726E20657D2C77616974556E';
wwv_flow_api.g_varchar2_table(396) := '74696C3A66756E6374696F6E28742C65297B766172206E3D746869733B7428293F6528293A73657454696D656F7574282866756E6374696F6E28297B6E2E77616974556E74696C28742C65297D292C313030297D2C617265417272617973457175616C3A';
wwv_flow_api.g_varchar2_table(397) := '66756E6374696F6E28742C65297B696628742E6C656E677468213D652E6C656E6774682972657475726E21313B742E736F727428292C652E736F727428293B666F7228766172206E3D303B6E3C742E6C656E6774683B6E2B2B29696628745B6E5D213D65';
wwv_flow_api.g_varchar2_table(398) := '5B6E5D2972657475726E21313B72657475726E21307D2C6170706C79496E7465726E616C4D617070696E67733A66756E6374696F6E2874297B76617220653D7B7D2C6E3D746869732E6F7074696F6E732E6669656C644D617070696E67733B666F722876';
wwv_flow_api.g_varchar2_table(399) := '6172206120696E206E296E2E6861734F776E50726F7065727479286129262628655B6E5B615D5D3D61293B72657475726E20746869732E6170706C794D617070696E677328652C74297D2C6170706C7945787465726E616C4D617070696E67733A66756E';
wwv_flow_api.g_varchar2_table(400) := '6374696F6E2874297B76617220653D746869732E6F7074696F6E732E6669656C644D617070696E67733B72657475726E20746869732E6170706C794D617070696E677328652C74297D2C6170706C794D617070696E67733A66756E6374696F6E28742C65';
wwv_flow_api.g_varchar2_table(401) := '297B766172206E3D7B7D3B666F7228766172206120696E2065297B6966286120696E2074296E5B745B615D5D3D655B615D7D72657475726E206E7D7D3B742E666E2E636F6D6D656E74733D66756E6374696F6E286E297B72657475726E20746869732E65';
wwv_flow_api.g_varchar2_table(402) := '616368282866756E6374696F6E28297B76617220613D4F626A6563742E6372656174652865293B742E6461746128746869732C22636F6D6D656E7473222C61292C612E696E6974286E7C7C7B7D2C74686973297D29297D7D29293B0A2F2F2320736F7572';
wwv_flow_api.g_varchar2_table(403) := '63654D617070696E6755524C3D6A71756572792D636F6D6D656E74732E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(51620018752630703970)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/jquery-comments.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E434F4D4D454E54533D77696E646F772E434F4D4D454E54537C7C7B7D2C434F4D4D454E54532E696E697469616C697A653D66756E6374696F6E28652C6E297B76617220693D652E66756E6374696F6E616C69746965732E726567696F6E';
wwv_flow_api.g_varchar2_table(2) := '49642C743D434F4D4D454E54532E61646450696E67734A534F4E28652E636F6D6D656E74732C652E70696E67696E674C697374292C733D7B656E61626C655570766F74696E673A21312C656E61626C655265706C79696E673A21302C656E61626C654465';
wwv_flow_api.g_varchar2_table(3) := '6C6574696E673A652E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E672C656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965733A652E66756E6374696F6E616C69746965732E656E61626C6544656C';
wwv_flow_api.g_varchar2_table(4) := '6574696E67436F6D6D656E74576974685265706C6965732C656E61626C6545646974696E673A652E66756E6374696F6E616C69746965732E656E61626C6545646974696E672C656E61626C6550696E67696E673A652E66756E6374696F6E616C69746965';
wwv_flow_api.g_varchar2_table(5) := '732E656E61626C6550696E67696E672C676574436F6D6D656E74733A66756E6374696F6E28652C6E297B652874297D2C73656172636855736572733A66756E6374696F6E286E2C692C74297B6928434F4D4D454E54532E66696C74657250696E67734C69';
wwv_flow_api.g_varchar2_table(6) := '737428652E70696E67696E674C6973742C6E29297D2C706F7374436F6D6D656E743A66756E6374696F6E286E2C692C74297B617065782E7365727665722E706C7567696E28652E66756E6374696F6E616C69746965732E616A61784964656E7469666965';
wwv_flow_api.g_varchar2_table(7) := '722C7B7830313A2249222C7830323A6E2E69642C7830333A6E2E706172656E742C7830343A6E2E636F6E74656E742C7830353A6E2E66756C6C6E616D652C7830363A22494E53434F4D4D454E54227D2C7B737563636573733A66756E6374696F6E286529';
wwv_flow_api.g_varchar2_table(8) := '7B636F6E736F6C652E6C6F67286E292C69286E297D2C6572726F723A66756E6374696F6E28652C6E2C69297B617065782E6D6573736167652E616C65727428652E726573706F6E73654A534F4E2E6D657373616765297D7D297D2C64656C657465436F6D';
wwv_flow_api.g_varchar2_table(9) := '6D656E743A66756E6374696F6E286E2C692C74297B76617220733D21303B652E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965732626617065782E7365727665722E706C7567696E';
wwv_flow_api.g_varchar2_table(10) := '28652E66756E6374696F6E616C69746965732E616A61784964656E7469666965722C7B7830313A2244222C7830323A6E2E69642C7830333A6E2E706172656E742C7830343A6E2E636F6E74656E742C7830353A6E2E66756C6C6E616D652C7830363A2244';
wwv_flow_api.g_varchar2_table(11) := '454C5245504C494553227D2C7B737563636573733A66756E6374696F6E2865297B733D652E737563636573737D2C6572726F723A66756E6374696F6E28652C6E2C69297B733D21312C617065782E6D6573736167652E616C65727428652E726573706F6E';
wwv_flow_api.g_varchar2_table(12) := '73654A534F4E2E6D657373616765297D7D292C21652E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965732626732626617065782E7365727665722E706C7567696E28652E66756E63';
wwv_flow_api.g_varchar2_table(13) := '74696F6E616C69746965732E616A61784964656E7469666965722C7B7830313A2244222C7830323A6E2E69642C7830333A6E2E706172656E742C7830343A6E2E636F6E74656E742C7830353A6E2E66756C6C6E616D652C7830363A2244454C434F4D4D45';
wwv_flow_api.g_varchar2_table(14) := '4E54227D2C7B737563636573733A66756E6374696F6E2865297B733D652E737563636573737D2C6572726F723A66756E6374696F6E28652C6E2C69297B733D21312C617065782E6D6573736167652E616C65727428652E726573706F6E73654A534F4E2E';
wwv_flow_api.g_varchar2_table(15) := '6D657373616765297D7D292C21652E66756E6374696F6E616C69746965732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C6965732626732626617065782E7365727665722E706C7567696E28652E66756E6374696F6E616C69';
wwv_flow_api.g_varchar2_table(16) := '746965732E616A61784964656E7469666965722C7B7830313A2255222C7830323A6E2E69642C7830333A6E2E706172656E742C7830343A6E2E636F6E74656E742C7830353A6E2E66756C6C6E616D652C7830363A225550445245504C494553227D2C7B73';
wwv_flow_api.g_varchar2_table(17) := '7563636573733A66756E6374696F6E2865297B733D652E737563636573737D2C6572726F723A66756E6374696F6E28652C6E2C69297B617065782E6D6573736167652E616C65727428652E726573706F6E73654A534F4E2E6D657373616765297D7D292C';
wwv_flow_api.g_varchar2_table(18) := '73262669286E297D2C707574436F6D6D656E743A66756E6374696F6E286E2C692C74297B617065782E7365727665722E706C7567696E28652E66756E6374696F6E616C69746965732E616A61784964656E7469666965722C7B7830313A2255222C783032';
wwv_flow_api.g_varchar2_table(19) := '3A6E2E69642C7830333A6E2E706172656E742C7830343A6E2E636F6E74656E742C7830353A6E2E66756C6C6E616D652C7830363A22555044434F4D4D454E54227D2C7B737563636573733A66756E6374696F6E2865297B69286E297D2C6572726F723A66';
wwv_flow_api.g_varchar2_table(20) := '756E6374696F6E28652C6E2C69297B617065782E6D6573736167652E616C65727428652E726573706F6E73654A534F4E2E6D657373616765297D7D292C69286E297D7D3B6E26262266756E6374696F6E223D3D747970656F66206E26266E2E63616C6C28';
wwv_flow_api.g_varchar2_table(21) := '746869732C65292C617065782E726567696F6E2E63726561746528692C7B747970653A22617065782D726567696F6E2D636F6D6D656E7473227D292C24282223222B69292E636F6D6D656E74732873292C24282223222B69292E66696E6428222E616374';
wwv_flow_api.g_varchar2_table(22) := '696F6E2E6564697422292E61747472282274797065222C22627574746F6E22297D2C434F4D4D454E54532E63726561746550696E67696E676C6973744A534F4E3D66756E6374696F6E2865297B766172206E3D7B7D3B72657475726E20652E666F724561';
wwv_flow_api.g_varchar2_table(23) := '6368282866756E6374696F6E2865297B6E5B652E69645D3D652E66756C6C6E616D657D29292C6E7D2C434F4D4D454E54532E61646450696E67734A534F4E3D66756E6374696F6E28652C6E297B76617220693B72657475726E20652E666F724561636828';
wwv_flow_api.g_varchar2_table(24) := '2866756E6374696F6E2865297B693D434F4D4D454E54532E67657450696E6773496E537472696E6728652E636F6E74656E74292C652E70696E67733D434F4D4D454E54532E63726561746550696E67696E676C6973744A534F4E286E2E66696C74657228';
wwv_flow_api.g_varchar2_table(25) := '28653D3E692E696E636C7564657328652E6964292929297D29292C657D2C434F4D4D454E54532E67657450696E6773496E537472696E673D66756E6374696F6E2865297B72657475726E20652E7265706C616365416C6C282F5B5E405C645D2F672C2222';
wwv_flow_api.g_varchar2_table(26) := '292E73706C697428224022292E6D6170284E756D626572297D2C434F4D4D454E54532E66696C74657250696E67734C6973743D66756E6374696F6E28652C6E297B76617220693D6E657720526567457870286E2E746F5570706572436173652829293B72';
wwv_flow_api.g_varchar2_table(27) := '657475726E20652E66696C7465722828653D3E652E66756C6C6E616D652E746F55707065724361736528292E6D6174636828692929297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(51678353006496873311)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
