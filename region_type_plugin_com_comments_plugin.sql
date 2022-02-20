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
,p_release=>'21.2.0'
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
--   Date and Time:   13:05 Sunday February 20, 2022
--   Exported By:     BALDOGI.RICHARD@REMEDIOS.HU
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 39826684832934841956
--   Manifest End
--   Version:         21.2.0
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
'--  This plug-in provides you a region where you can write comments.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/baldogiRichard/apex-comments',
'--',
'-- =============================================================================',
'',
'function render',
'  ( p_region              in apex_plugin.t_region',
'  , p_plugin              in apex_plugin.t_plugin',
'  , p_is_printer_friendly in boolean',
'  )',
'return apex_plugin.t_region_render_result',
'as',
'    l_result                        apex_plugin.t_region_render_result;',
'',
'    --region source',
'    l_source                        p_region.source%type       := p_region.source;',
'    l_context                       apex_exec.t_context;',
'    l_init_js                       varchar2(32767)            := nvl(apex_plugin_util.replace_substitutions(p_region.init_javascript_code), ''undefined'');',
'',
'    --pinging source',
'    l_context_pinging               apex_exec.t_context;',
'    l_pinging_list                  p_region.attribute_15%type := p_region.attribute_15;',
'',
'    --enable deleting with replies',
'    l_enable_delete                 boolean := (p_region.attribute_19 = ''ENABLE'');',
'    l_enable_delete_w_replies       boolean := (p_region.attribute_20 = ''ENABLE'');',
'',
'    --attributes',
'    l_id_col                        p_region.attribute_01%type := p_region.attribute_01;',
'    l_parent_col                    p_region.attribute_02%type := p_region.attribute_02;',
'    l_created_date_col              p_region.attribute_03%type := p_region.attribute_03;',
'    l_modified_date_col             p_region.attribute_04%type := p_region.attribute_04;',
'    l_content_col                   p_region.attribute_05%type := p_region.attribute_05;',
'    l_creator_col                   p_region.attribute_06%type := p_region.attribute_06;',
'    l_fullname_col                  p_region.attribute_07%type := p_region.attribute_07;',
'    l_profile_picture_url_col       p_region.attribute_08%type := p_region.attribute_08;',
'    l_created_by_admin_col          p_region.attribute_09%type := p_region.attribute_09;',
'    l_created_by_current_user_col   p_region.attribute_10%type := p_region.attribute_10;',
'    l_is_new_col                    p_region.attribute_11%type := p_region.attribute_11;',
'    ',
'    l_reply                         boolean := (p_region.attribute_12 = ''ENABLE'');',
'    l_pinging                       boolean := (p_region.attribute_14 = ''ENABLE'');',
'    l_editing                       boolean := (p_region.attribute_18 = ''ENABLE'');',
'',
'    --query variables',
'    l_id_col_pos                        pls_integer;',
'    l_parent_col_pos                    pls_integer;',
'    l_created_date_col_pos              pls_integer;',
'    l_modified_date_col_pos             pls_integer;',
'    l_content_col_pos                   pls_integer;',
'    l_creator_col_pos                   pls_integer;',
'    l_fullname_col_pos                  pls_integer;',
'    l_profile_picture_url_col_pos       pls_integer;',
'    l_created_by_admin_col_pos          pls_integer;',
'    l_created_by_current_user_col_pos   pls_integer;',
'    l_is_new_col_pol                    pls_integer;',
'',
'    l_pinging_id                        pls_integer;',
'    l_pinging_name                      pls_integer;',
'',
'    l_id_col_val                        number;',
'    l_parent_col_val                    number;',
'    l_created_date_col_val              date;',
'    l_modified_date_col_val             date;',
'    l_content_col_val                   clob;',
'    l_creator_col_val                   number;',
'    l_fullname_col_val                  varchar2(100);',
'    l_profile_picture_url_col_val       varchar2(1500);',
'    l_created_by_admin_col_val          varchar2(10);',
'    l_created_by_current_user_col_val   varchar2(10);',
'    l_is_new_col_val                    varchar2(10);',
'',
'    l_pinging_id_val                    number;',
'    l_pinging_name_val                  varchar2(100);',
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
'        apex_json.write(''enableReplying''                   , case when l_reply                    then TRUE else FALSE end   );',
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
'',
'        apex_json.initialize_clob_output;',
'',
'        apex_json.open_array;',
'',
'        while apex_exec.next_row(l_context_pinging) ',
'        loop',
'',
'            l_pinging_id_val   := apex_exec.get_number   (    l_context_pinging, l_pinging_id     );',
'            l_pinging_name_val := apex_exec.get_varchar2 (    l_context_pinging, l_pinging_name   );',
'',
'            apex_json.open_object;',
'',
'                apex_json.write( '''' || l_pinging_id_val, l_pinging_name_val );',
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
'    if l_reply then',
'        l_parent_col_pos                    := apex_exec.get_column_position(l_context, l_parent_col);',
'    end if;',
'',
'    if l_editing  then',
'',
'        l_modified_date_col_pos             := apex_exec.get_column_position(l_context, l_modified_date_col);',
'        l_created_by_current_user_col_pos   := apex_exec.get_column_position(l_context, l_created_by_current_user_col);',
'',
'    end if;',
'',
'    l_created_date_col_pos              := apex_exec.get_column_position(l_context, l_created_date_col);',
'    l_id_col_pos                        := apex_exec.get_column_position(l_context, l_id_col);',
'    l_content_col_pos                   := apex_exec.get_column_position(l_context, l_content_col);',
'    l_creator_col_pos                   := apex_exec.get_column_position(l_context, l_creator_col_pos);',
'    l_fullname_col_pos                  := apex_exec.get_column_position(l_context, l_fullname_col);',
'    l_profile_picture_url_col_pos       := apex_exec.get_column_position(l_context, l_profile_picture_url_col);',
'    l_created_by_admin_col_pos          := apex_exec.get_column_position(l_context, l_created_by_admin_col);',
'    l_is_new_col_pol                    := apex_exec.get_column_position(l_context, l_is_new_col);',
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
'            if l_reply then',
'                apex_json.write(''parent''                  , l_parent_col_val);',
'            end if;',
'',
'            if l_editing  then',
'                apex_json.write(''modified''                , l_modified_date_col_val);',
'                apex_json.write(''createdByCurrentUser''    , l_created_by_current_user_col_val);',
'            end if;',
'',
'            apex_json.write(''id''                      , l_id_col_val);',
'            apex_json.write(''created''                 , l_created_date_col_val);',
'            apex_json.write(''content''                 , l_content_col_val);',
'            apex_json.write(''creator''                 , l_creator_col_val);',
'            apex_json.write(''fullname''                , l_fullname_col_val);',
'            apex_json.write(''profilePictureURL''       , l_profile_picture_url_col_val);',
'            apex_json.write(''createdByAdmin''          , l_created_by_admin_col_val);',
'            apex_json.write(''isNew''                   , l_is_new_col_val);',
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
'    apex_json.initialize_clob_output;    ',
'',
'    apex_json.open_object;',
'',
'        if l_pinging then',
'            apex_json.write(''pingingList''   ,   l_pinging_json          );',
'        end if;',
'',
'        apex_json.write(''comments''          ,   l_comments_json         );',
'        apex_json.write(''functionalitites''  ,   l_functionalities_json  );',
'',
'    apex_json.close_object;',
'    ',
'    apex_javascript.add_onload_code(p_code => ''COMMENTS.initialize('' || apex_json.get_clob_output || '', ''|| l_init_js ||'');'');',
'    ',
'    apex_json.free_output;',
'    ',
'    return l_result;',
'end render;',
'',
'function ajax',
'    ( p_region in apex_plugin.t_region',
'    , p_plugin in apex_plugin.t_plugin ',
'    )',
'return apex_plugin.t_region_ajax_result',
'as',
'    l_result apex_plugin.t_region_ajax_result;',
'',
'    --ajax values',
'    l_action        varchar2(10) := apex_application.g_x01;',
'    l_id            number       := apex_application.g_x02;',
'    l_parent_id     number       := apex_application.g_x03;',
'    l_comment       clob         := apex_application.g_x04;',
'',
'    --attributes',
'    l_id_col        p_region.attribute_01%type := p_region.attribute_01;',
'    l_parent_col    p_region.attribute_02%type := p_region.attribute_02;',
'    l_content_col   p_region.attribute_05%type := p_region.attribute_05;',
'',
'    --region source',
'    l_source   p_region.source%type    := p_region.source;',
'    l_context  apex_exec.t_context;',
'    l_filters  apex_exec.t_filters;',
'',
'    --dml operation',
'    l_enable_delete_w_replies       boolean                   := (p_region.attribute_20 = ''ENABLE'');',
'    l_operation                     apex_exec.t_dml_operation := case when l_action = ''I''',
'                                                                        then ''c_dml_operation_insert''',
'                                                                      when l_action = ''U''',
'                                                                        then ''c_dml_operation_update''',
'                                                                      when l_action = ''D''',
'                                                                        then ''c_dml_operation_delete''',
'                                                                    end;',
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
'    --prepare and execute dml -- delete comment',
'    if l_action in (''U'',''D'') then',
'',
'        apex_exec.add_filter',
'            ( p_filters     => l_filters',
'            , p_filter_type => apex_exec.c_filter_eq',
'            , p_column_name => l_id_col',
'            , p_value       => l_id ',
'            );',
'',
'    end if;',
'',
'    l_context := apex_exec.open_query_context',
'        ( p_location        => apex_exec.c_location_local_db',
'        , p_sql_query       => l_source',
'        , p_filters         => l_filters ',
'        , p_total_row_count => true',
'        );',
'',
'    apex_exec.add_dml_row(',
'       p_context            => l_context',
'     , p_operation          => l_operation     ',
'    );',
'',
'    if l_action = ''U'' then',
'',
'        apex_exec.set_value(',
'          p_context            => l_context',
'        , p_column_name        => l_content_col',
'        , p_value              => l_comment',
'        );',
'',
'    end if;',
'',
'    if l_action = ''I'' then',
'',
'        apex_exec.set_value(',
'          p_context            => l_context',
'        , p_column_name        => l_parent_col',
'        , p_value              => l_parent_id',
'        );',
'',
'        if l_parent_id is not null then',
'',
'            apex_exec.set_value(',
'              p_context            => l_context',
'            , p_column_name        => l_parent_col',
'            , p_value              => l_parent_id',
'            );',
'',
'        end if;',
'',
'    end if;',
'    ',
'    apex_exec.execute_dml(',
'       p_context           => l_context',
'     , p_continue_on_error => false',
'    );',
'',
'    apex_exec.clear_dml_rows(l_context);',
'',
'    apex_exec.close(l_context);',
'',
'    --delete replies with parent comment if enabled',
'    if l_action = ''D'' and l_enable_delete_w_replies then',
'',
'        apex_exec.add_filter',
'            ( p_filters     => l_filters',
'            , p_filter_type => apex_exec.c_filter_eq',
'            , p_column_name => l_parent_col',
'            , p_value       => l_id ',
'            );',
'',
'        l_context := apex_exec.open_query_context',
'            ( p_location        => apex_exec.c_location_local_db',
'            , p_sql_query       => l_source',
'            , p_filters         => l_filters ',
'            , p_total_row_count => true',
'            );',
'',
'        while apex_exec.next_row(l_context) ',
'        loop',
'',
'            apex_exec.add_dml_row(',
'                  p_context            => l_context',
'                , p_operation        => l_operation     ',
'                );',
'',
'        end loop;',
'',
'        apex_exec.execute_dml(',
'              p_context           => l_context',
'            , p_continue_on_error => false',
'        );',
'',
'        apex_exec.clear_dml_rows(l_context);',
'',
'        apex_exec.close(l_context);',
'',
'    end if;',
'',
'    return l_result;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'SOURCE_LOCATION:AJAX_ITEMS_TO_SUBMIT:ESCAPE_OUTPUT:INIT_JAVASCRIPT_CODE:COLUMNS:HEADING_ALIGNMENT:VALUE_ALIGNMENT:VALUE_CSS:VALUE_ATTRIBUTE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'21.2'
,p_about_url=>'https://github.com/baldogiRichard/apex-comments'
,p_files_version=>52
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
,p_column_data_types=>'NUMBER'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>'ID column for the displayed comment.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39855043135161414281)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>130
,p_prompt=>'Comment ID (Parent):'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>false
,p_column_data_types=>'NUMBER'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(40276470872037887625)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ENABLE'
,p_help_text=>'Parent ID column for the displayed comment. If replies are available then the parent ID comment where the user have replied must be available.'
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
,p_display_sequence=>190
,p_prompt=>'Modified date:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'DATE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(40290112733906052207)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ENABLE'
,p_help_text=>'The date when the comment was modified.'
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
,p_help_text=>'The actual text which was written by the user.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39855641036855778603)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Creator ID:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>true
,p_column_data_types=>'NUMBER'
,p_is_translatable=>false
,p_help_text=>'ID of the user who wrote the comment.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39856377250803445788)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Username:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>false
,p_column_data_types=>'VARCHAR2'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The name of the user who created the comment.',
'',
'Return value type: VARCHAR2',
'',
'Default value: ''-'' if the user not exists anymore.'))
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
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Profile picture URL of the user.',
'',
'Return value type: VARCHAR2',
'',
'Default value: empty string ('''')'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39857218816586800352)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Created by Admin:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>false
,p_column_data_types=>'VARCHAR2:NUMBER'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The column which indicates whether the comment was made by the admin or not.',
'',
'Return value: true or false',
'',
'Default value: false'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(39857278395714805302)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>200
,p_prompt=>'Created by current user:'
,p_attribute_type=>'REGION SOURCE COLUMN'
,p_is_required=>false
,p_column_data_types=>'VARCHAR2:NUMBER'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(40290112733906052207)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ENABLE'
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
,p_is_required=>false
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
 p_id=>wwv_flow_api.id(40276470872037887625)
,p_plugin_id=>wwv_flow_api.id(39826684832934841956)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Reply'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'DISABLE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Select ''Enable'' if you want to make replies to comments available.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40276474517537890372)
,p_plugin_attribute_id=>wwv_flow_api.id(40276470872037887625)
,p_display_sequence=>10
,p_display_value=>'Enable'
,p_return_value=>'ENABLE'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(40276476842778891210)
,p_plugin_attribute_id=>wwv_flow_api.id(40276470872037887625)
,p_display_sequence=>20
,p_display_value=>'Disable'
,p_return_value=>'DISABLE'
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
'from       table'))
);
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
,p_is_translatable=>false
,p_lov_type=>'STATIC'
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
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(41270604931950703306)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'ENABLE'
,p_lov_type=>'STATIC'
,p_help_text=>'If enabled the comment and the replies are automatically deleted.'
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
wwv_flow_api.g_varchar2_table(177) := '0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204170706E6564206C69737420746F20444F4D0A202020202020202020202020746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D22636F6D6D';
wwv_flow_api.g_varchar2_table(178) := '656E7473225D27292E70726570656E6428636F6D6D656E744C697374293B0A20202020202020207D2C0A0A20202020202020206372656174654174746163686D656E74733A2066756E6374696F6E2829207B0A2020202020202020202020207661722073';
wwv_flow_api.g_varchar2_table(179) := '656C66203D20746869733B0A0A2020202020202020202020202F2F2043726561746520746865206C69737420656C656D656E74206265666F726520617070656E64696E6720746F20444F4D20696E206F7264657220746F20726561636820626574746572';
wwv_flow_api.g_varchar2_table(180) := '20706572666F726D616E63650A202020202020202020202020746869732E24656C2E66696E642827236174746163686D656E742D6C69737427292E72656D6F766528293B0A202020202020202020202020766172206174746163686D656E744C69737420';
wwv_flow_api.g_varchar2_table(181) := '3D202428273C756C2F3E272C207B0A2020202020202020202020202020202069643A20276174746163686D656E742D6C697374272C0A2020202020202020202020202020202027636C617373273A20276D61696E270A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(182) := '3B0A0A202020202020202020202020766172206174746163686D656E7473203D20746869732E6765744174746163686D656E747328293B0A202020202020202020202020746869732E736F7274436F6D6D656E7473286174746163686D656E74732C2027';
wwv_flow_api.g_varchar2_table(183) := '6E657765737427293B0A20202020202020202020202024286174746163686D656E7473292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B0A2020202020202020202020202020202073656C662E6164644174';
wwv_flow_api.g_varchar2_table(184) := '746163686D656E7428636F6D6D656E744D6F64656C2C206174746163686D656E744C697374293B0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204170706E6564206C69737420746F20444F4D0A202020202020202020';
wwv_flow_api.g_varchar2_table(185) := '202020746869732E24656C2E66696E6428275B646174612D636F6E7461696E65723D226174746163686D656E7473225D27292E70726570656E64286174746163686D656E744C697374293B0A20202020202020207D2C0A0A202020202020202061646443';
wwv_flow_api.g_varchar2_table(186) := '6F6D6D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2C20636F6D6D656E744C6973742C2070726570656E64436F6D6D656E7429207B0A202020202020202020202020636F6D6D656E744C697374203D20636F6D6D656E744C69737420';
wwv_flow_api.g_varchar2_table(187) := '7C7C20746869732E24656C2E66696E64282723636F6D6D656E742D6C69737427293B0A20202020202020202020202076617220636F6D6D656E74456C203D20746869732E637265617465436F6D6D656E74456C656D656E7428636F6D6D656E744D6F6465';
wwv_flow_api.g_varchar2_table(188) := '6C293B0A0A2020202020202020202020202F2F20436173653A207265706C790A202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A202020202020202020202020202020207661722064697265637450617265';
wwv_flow_api.g_varchar2_table(189) := '6E74456C203D20636F6D6D656E744C6973742E66696E6428272E636F6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E706172656E742B27225D27293B0A0A202020202020202020202020202020202F2F2052652D72656E6465';
wwv_flow_api.g_varchar2_table(190) := '7220616374696F6E20626172206F662064697265637420706172656E7420656C656D656E740A20202020202020202020202020202020746869732E726552656E646572436F6D6D656E74416374696F6E42617228636F6D6D656E744D6F64656C2E706172';
wwv_flow_api.g_varchar2_table(191) := '656E74293B0A0A202020202020202020202020202020202F2F20466F726365207265706C69657320696E746F206F6E65206C6576656C206F6E6C790A20202020202020202020202020202020766172206F757465724D6F7374506172656E74203D206469';
wwv_flow_api.g_varchar2_table(192) := '72656374506172656E74456C2E706172656E747328272E636F6D6D656E7427292E6C61737428293B0A202020202020202020202020202020206966286F757465724D6F7374506172656E742E6C656E677468203D3D203029206F757465724D6F73745061';
wwv_flow_api.g_varchar2_table(193) := '72656E74203D20646972656374506172656E74456C3B0A0A202020202020202020202020202020202F2F20417070656E6420656C656D656E7420746F20444F4D0A20202020202020202020202020202020766172206368696C64436F6D6D656E7473456C';
wwv_flow_api.g_varchar2_table(194) := '203D206F757465724D6F7374506172656E742E66696E6428272E6368696C642D636F6D6D656E747327293B0A2020202020202020202020202020202076617220636F6D6D656E74696E674669656C64203D206368696C64436F6D6D656E7473456C2E6669';
wwv_flow_api.g_varchar2_table(195) := '6E6428272E636F6D6D656E74696E672D6669656C6427293B0A20202020202020202020202020202020696628636F6D6D656E74696E674669656C642E6C656E67746829207B0A2020202020202020202020202020202020202020636F6D6D656E74696E67';
wwv_flow_api.g_varchar2_table(196) := '4669656C642E6265666F726528636F6D6D656E74456C290A202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020206368696C64436F6D6D656E7473456C2E617070656E6428636F6D6D656E7445';
wwv_flow_api.g_varchar2_table(197) := '6C293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F2055706461746520746F67676C6520616C6C202D627574746F6E0A20202020202020202020202020202020746869732E757064617465546F67676C';
wwv_flow_api.g_varchar2_table(198) := '65416C6C427574746F6E286F757465724D6F7374506172656E74293B0A0A2020202020202020202020202F2F20436173653A206D61696E206C6576656C20636F6D6D656E740A2020202020202020202020207D20656C7365207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(199) := '2020202020202069662870726570656E64436F6D6D656E7429207B0A2020202020202020202020202020202020202020636F6D6D656E744C6973742E70726570656E6428636F6D6D656E74456C293B0A202020202020202020202020202020207D20656C';
wwv_flow_api.g_varchar2_table(200) := '7365207B0A2020202020202020202020202020202020202020636F6D6D656E744C6973742E617070656E6428636F6D6D656E74456C293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A';
wwv_flow_api.g_varchar2_table(201) := '20202020202020206164644174746163686D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2C20636F6D6D656E744C69737429207B0A202020202020202020202020636F6D6D656E744C697374203D20636F6D6D656E744C697374207C';
wwv_flow_api.g_varchar2_table(202) := '7C20746869732E24656C2E66696E642827236174746163686D656E742D6C69737427293B0A20202020202020202020202076617220636F6D6D656E74456C203D20746869732E637265617465436F6D6D656E74456C656D656E7428636F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(203) := '64656C293B0A202020202020202020202020636F6D6D656E744C6973742E70726570656E6428636F6D6D656E74456C293B0A20202020202020207D2C0A0A202020202020202072656D6F7665436F6D6D656E743A2066756E6374696F6E28636F6D6D656E';
wwv_flow_api.g_varchar2_table(204) := '74496429207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B636F6D6D656E7449645D3B0A0A2020';
wwv_flow_api.g_varchar2_table(205) := '202020202020202020202F2F2052656D6F7665206368696C6420636F6D6D656E7473207265637572736976656C790A202020202020202020202020766172206368696C64436F6D6D656E7473203D20746869732E6765744368696C64436F6D6D656E7473';
wwv_flow_api.g_varchar2_table(206) := '28636F6D6D656E744D6F64656C2E6964293B0A20202020202020202020202024286368696C64436F6D6D656E7473292E656163682866756E6374696F6E28696E6465782C206368696C64436F6D6D656E7429207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(207) := '2073656C662E72656D6F7665436F6D6D656E74286368696C64436F6D6D656E742E6964293B0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2055706461746520746865206368696C64206172726179206F66206F757465';
wwv_flow_api.g_varchar2_table(208) := '726D6F737420706172656E740A202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A20202020202020202020202020202020766172206F757465726D6F7374506172656E74203D20746869732E6765744F7574';
wwv_flow_api.g_varchar2_table(209) := '65726D6F7374506172656E7428636F6D6D656E744D6F64656C2E706172656E74293B0A2020202020202020202020202020202076617220696E646578546F52656D6F7665203D206F757465726D6F7374506172656E742E6368696C64732E696E6465784F';
wwv_flow_api.g_varchar2_table(210) := '6628636F6D6D656E744D6F64656C2E6964293B0A202020202020202020202020202020206F757465726D6F7374506172656E742E6368696C64732E73706C69636528696E646578546F52656D6F76652C2031293B0A2020202020202020202020207D0A0A';
wwv_flow_api.g_varchar2_table(211) := '2020202020202020202020202F2F2052656D6F76652074686520636F6D6D656E742066726F6D2064617461206D6F64656C0A20202020202020202020202064656C65746520746869732E636F6D6D656E7473427949645B636F6D6D656E7449645D3B0A0A';
wwv_flow_api.g_varchar2_table(212) := '20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B636F6D6D656E7449642B27225D27293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(213) := '76617220706172656E74456C203D20636F6D6D656E74456C656D656E74732E706172656E747328276C692E636F6D6D656E7427292E6C61737428293B0A0A2020202020202020202020202F2F2052656D6F76652074686520656C656D656E740A20202020';
wwv_flow_api.g_varchar2_table(214) := '2020202020202020636F6D6D656E74456C656D656E74732E72656D6F766528293B0A0A2020202020202020202020202F2F205570646174652074686520746F67676C6520616C6C20627574746F6E0A202020202020202020202020746869732E75706461';
wwv_flow_api.g_varchar2_table(215) := '7465546F67676C65416C6C427574746F6E28706172656E74456C293B0A20202020202020207D2C0A0A202020202020202070726544656C6574654174746163686D656E743A2066756E6374696F6E28657629207B0A202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(216) := '20636F6D6D656E74696E674669656C64203D20242865762E63757272656E74546172676574292E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428290A202020202020202020202020766172206174746163686D65';
wwv_flow_api.g_varchar2_table(217) := '6E74456C203D20242865762E63757272656E74546172676574292E706172656E747328272E6174746163686D656E7427292E666972737428293B0A2020202020202020202020206174746163686D656E74456C2E72656D6F766528293B0A0A2020202020';
wwv_flow_api.g_varchar2_table(218) := '202020202020202F2F20436865636B206966207361766520627574746F6E206E6565647320746F20626520656E61626C65640A202020202020202020202020746869732E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64';
wwv_flow_api.g_varchar2_table(219) := '293B0A20202020202020207D2C0A0A2020202020202020707265536176654174746163686D656E74733A2066756E6374696F6E2866696C65732C20636F6D6D656E74696E674669656C6429207B0A2020202020202020202020207661722073656C66203D';
wwv_flow_api.g_varchar2_table(220) := '20746869733B0A0A20202020202020202020202069662866696C65732E6C656E67746829207B0A0A202020202020202020202020202020202F2F20456C656D656E74730A2020202020202020202020202020202069662821636F6D6D656E74696E674669';
wwv_flow_api.g_varchar2_table(221) := '656C642920636F6D6D656E74696E674669656C64203D20746869732E24656C2E66696E6428272E636F6D6D656E74696E672D6669656C642E6D61696E27293B0A202020202020202020202020202020207661722075706C6F6164427574746F6E203D2063';
wwv_flow_api.g_varchar2_table(222) := '6F6D6D656E74696E674669656C642E66696E6428272E636F6E74726F6C2D726F77202E75706C6F616427293B0A202020202020202020202020202020207661722069735265706C79203D2021636F6D6D656E74696E674669656C642E686173436C617373';
wwv_flow_api.g_varchar2_table(223) := '28276D61696E27293B0A20202020202020202020202020202020766172206174746163686D656E7473436F6E7461696E6572203D20636F6D6D656E74696E674669656C642E66696E6428272E636F6E74726F6C2D726F77202E6174746163686D656E7473';
wwv_flow_api.g_varchar2_table(224) := '27293B0A0A202020202020202020202020202020202F2F20437265617465206174746163686D656E74206D6F64656C730A20202020202020202020202020202020766172206174746163686D656E7473203D20242866696C6573292E6D61702866756E63';
wwv_flow_api.g_varchar2_table(225) := '74696F6E28696E6465782C2066696C65297B0A202020202020202020202020202020202020202072657475726E207B0A2020202020202020202020202020202020202020202020206D696D655F747970653A2066696C652E747970652C0A202020202020';
wwv_flow_api.g_varchar2_table(226) := '20202020202020202020202020202020202066696C653A2066696C650A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D293B0A0A202020202020202020202020202020202F2F2046696C746572206F75';
wwv_flow_api.g_varchar2_table(227) := '7420616C7265616479206164646564206174746163686D656E74730A20202020202020202020202020202020766172206578697374696E674174746163686D656E7473203D20746869732E6765744174746163686D656E747346726F6D436F6D6D656E74';
wwv_flow_api.g_varchar2_table(228) := '696E674669656C6428636F6D6D656E74696E674669656C64293B0A202020202020202020202020202020206174746163686D656E7473203D206174746163686D656E74732E66696C7465722866756E6374696F6E28696E6465782C206174746163686D65';
wwv_flow_api.g_varchar2_table(229) := '6E7429207B0A2020202020202020202020202020202020202020766172206475706C6963617465203D2066616C73653B0A0A20202020202020202020202020202020202020202F2F20436865636B206966207468652061747461636D656E74206E616D65';
wwv_flow_api.g_varchar2_table(230) := '20616E642073697A65206D617463686573207769746820616C7265616479206164646564206174746163686D656E740A202020202020202020202020202020202020202024286578697374696E674174746163686D656E7473292E656163682866756E63';
wwv_flow_api.g_varchar2_table(231) := '74696F6E28696E6465782C206578697374696E674174746163686D656E7429207B0A2020202020202020202020202020202020202020202020206966286174746163686D656E742E66696C652E6E616D65203D3D206578697374696E674174746163686D';
wwv_flow_api.g_varchar2_table(232) := '656E742E66696C652E6E616D65202626206174746163686D656E742E66696C652E73697A65203D3D206578697374696E674174746163686D656E742E66696C652E73697A6529207B0A202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(233) := '206475706C6963617465203D20747275653B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D293B0A0A202020202020202020202020202020202020202072657475726E20216475';
wwv_flow_api.g_varchar2_table(234) := '706C69636174653B0A202020202020202020202020202020207D293B0A0A202020202020202020202020202020202F2F20456E73757265207468617420746865206D61696E20636F6D6D656E74696E67206669656C642069732073686F776E2069662061';
wwv_flow_api.g_varchar2_table(235) := '74746163686D656E7473207765726520616464656420746F20746861740A20202020202020202020202020202020696628636F6D6D656E74696E674669656C642E686173436C61737328276D61696E272929207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(236) := '2020202020636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127292E747269676765722827636C69636B27293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F205365742062';
wwv_flow_api.g_varchar2_table(237) := '7574746F6E20737461746520746F206C6F6164696E670A20202020202020202020202020202020746869732E736574427574746F6E53746174652875706C6F6164427574746F6E2C2066616C73652C2074727565293B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(238) := '202020202F2F2056616C6964617465206174746163686D656E74730A20202020202020202020202020202020746869732E6F7074696F6E732E76616C69646174654174746163686D656E7473286174746163686D656E74732C2066756E6374696F6E2876';
wwv_flow_api.g_varchar2_table(239) := '616C6964617465644174746163686D656E747329207B0A0A202020202020202020202020202020202020202069662876616C6964617465644174746163686D656E74732E6C656E67746829C2A07B0A0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(240) := '202020202F2F20437265617465206174746163686D656E7420746167730A202020202020202020202020202020202020202020202020242876616C6964617465644174746163686D656E7473292E656163682866756E6374696F6E28696E6465782C2061';
wwv_flow_api.g_varchar2_table(241) := '74746163686D656E7429207B0A20202020202020202020202020202020202020202020202020202020766172206174746163686D656E74546167203D2073656C662E6372656174654174746163686D656E74546167456C656D656E74286174746163686D';
wwv_flow_api.g_varchar2_table(242) := '656E742C2074727565293B0A202020202020202020202020202020202020202020202020202020206174746163686D656E7473436F6E7461696E65722E617070656E64286174746163686D656E74546167293B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(243) := '20202020202020207D293B0A0A2020202020202020202020202020202020202020202020202F2F20436865636B206966207361766520627574746F6E206E6565647320746F20626520656E61626C65640A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(244) := '202020202073656C662E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64293B0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202F2F20526573657420627574';
wwv_flow_api.g_varchar2_table(245) := '746F6E2073746174650A202020202020202020202020202020202020202073656C662E736574427574746F6E53746174652875706C6F6164427574746F6E2C20747275652C2066616C7365293B0A202020202020202020202020202020207D293B0A2020';
wwv_flow_api.g_varchar2_table(246) := '202020202020202020207D0A0A2020202020202020202020202F2F20436C6561722074686520696E707574206669656C640A20202020202020202020202075706C6F6164427574746F6E2E66696E642827696E70757427292E76616C282727293B0A2020';
wwv_flow_api.g_varchar2_table(247) := '2020202020207D2C0A0A2020202020202020757064617465546F67676C65416C6C427574746F6E3A2066756E6374696F6E28706172656E74456C29207B0A2020202020202020202020202F2F20446F6E27742068696465207265706C696573206966206D';
wwv_flow_api.g_varchar2_table(248) := '61785265706C69657356697369626C65206973206E756C6C206F7220756E646566696E65640A20202020202020202020202069662028746869732E6F7074696F6E732E6D61785265706C69657356697369626C65203D3D206E756C6C292072657475726E';
wwv_flow_api.g_varchar2_table(249) := '3B0A0A202020202020202020202020766172206368696C64436F6D6D656E7473456C203D20706172656E74456C2E66696E6428272E6368696C642D636F6D6D656E747327293B0A202020202020202020202020766172206368696C64436F6D6D656E7473';
wwv_flow_api.g_varchar2_table(250) := '203D206368696C64436F6D6D656E7473456C2E66696E6428272E636F6D6D656E7427292E6E6F7428272E68696464656E27293B0A20202020202020202020202076617220746F67676C65416C6C427574746F6E203D206368696C64436F6D6D656E747345';
wwv_flow_api.g_varchar2_table(251) := '6C2E66696E6428276C692E746F67676C652D616C6C27293B0A2020202020202020202020206368696C64436F6D6D656E74732E72656D6F7665436C6173732827746F67676C61626C652D7265706C7927293B0A0A2020202020202020202020202F2F2053';
wwv_flow_api.g_varchar2_table(252) := '656C656374207265706C69657320746F2062652068696464656E0A20202020202020202020202069662028746869732E6F7074696F6E732E6D61785265706C69657356697369626C65203D3D3D203029207B0A2020202020202020202020202020202076';
wwv_flow_api.g_varchar2_table(253) := '617220746F67676C61626C655265706C696573203D206368696C64436F6D6D656E74733B0A2020202020202020202020207D20656C7365207B0A2020202020202020202020202020202076617220746F67676C61626C655265706C696573203D20636869';
wwv_flow_api.g_varchar2_table(254) := '6C64436F6D6D656E74732E736C69636528302C202D746869732E6F7074696F6E732E6D61785265706C69657356697369626C65293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20416464206964656E74696679696E6720';
wwv_flow_api.g_varchar2_table(255) := '636C61737320666F722068696464656E207265706C69657320736F20746865792063616E20626520746F67676C65640A202020202020202020202020746F67676C61626C655265706C6965732E616464436C6173732827746F67676C61626C652D726570';
wwv_flow_api.g_varchar2_table(256) := '6C7927293B0A0A2020202020202020202020202F2F2053686F7720616C6C207265706C696573206966207265706C6965732061726520657870616E6465640A202020202020202020202020696628746F67676C65416C6C427574746F6E2E66696E642827';
wwv_flow_api.g_varchar2_table(257) := '7370616E2E7465787427292E746578742829203D3D20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E686964655265706C696573546578742929207B0A20202020202020202020202020202020746F';
wwv_flow_api.g_varchar2_table(258) := '67676C61626C655265706C6965732E616464436C617373282776697369626C6527293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F204D616B652073757265207468617420746F67676C6520616C6C20627574746F6E2069';
wwv_flow_api.g_varchar2_table(259) := '732070726573656E740A2020202020202020202020206966286368696C64436F6D6D656E74732E6C656E677468203E20746869732E6F7074696F6E732E6D61785265706C69657356697369626C6529207B0A0A202020202020202020202020202020202F';
wwv_flow_api.g_varchar2_table(260) := '2F20417070656E6420627574746F6E20746F20746F67676C6520616C6C207265706C696573206966206E65636573736172790A2020202020202020202020202020202069662821746F67676C65416C6C427574746F6E2E6C656E67746829207B0A0A2020';
wwv_flow_api.g_varchar2_table(261) := '202020202020202020202020202020202020746F67676C65416C6C427574746F6E203D202428273C6C692F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A2027746F67676C652D616C6C20686967686C69';
wwv_flow_api.g_varchar2_table(262) := '6768742D666F6E742D626F6C64270A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020202020202076617220746F67676C65416C6C427574746F6E54657874203D202428273C7370616E2F3E272C207B0A';
wwv_flow_api.g_varchar2_table(263) := '20202020202020202020202020202020202020202020202027636C617373273A202774657874270A20202020202020202020202020202020202020207D293B0A2020202020202020202020202020202020202020766172206361726574203D202428273C';
wwv_flow_api.g_varchar2_table(264) := '7370616E2F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A20276361726574270A20202020202020202020202020202020202020207D293B0A0A20202020202020202020202020202020202020202F2F20';
wwv_flow_api.g_varchar2_table(265) := '417070656E6420746F67676C6520627574746F6E20746F20444F4D0A2020202020202020202020202020202020202020746F67676C65416C6C427574746F6E2E617070656E6428746F67676C65416C6C427574746F6E54657874292E617070656E642863';
wwv_flow_api.g_varchar2_table(266) := '61726574293B0A20202020202020202020202020202020202020206368696C64436F6D6D656E7473456C2E70726570656E6428746F67676C65416C6C427574746F6E293B0A202020202020202020202020202020207D0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(267) := '202020202F2F20557064617465207468652074657874206F6620746F67676C6520616C6C202D627574746F6E0A20202020202020202020202020202020746869732E736574546F67676C65416C6C427574746F6E5465787428746F67676C65416C6C4275';
wwv_flow_api.g_varchar2_table(268) := '74746F6E2C2066616C7365293B0A0A2020202020202020202020202F2F204D616B652073757265207468617420746F67676C6520616C6C20627574746F6E206973206E6F742070726573656E740A2020202020202020202020207D20656C7365207B0A20';
wwv_flow_api.g_varchar2_table(269) := '202020202020202020202020202020746F67676C65416C6C427574746F6E2E72656D6F766528293B0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020757064617465546F67676C65416C6C427574746F6E733A2066';
wwv_flow_api.g_varchar2_table(270) := '756E6374696F6E2829207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220636F6D6D656E744C697374203D20746869732E24656C2E66696E64282723636F6D6D656E742D6C69737427';
wwv_flow_api.g_varchar2_table(271) := '293B0A0A2020202020202020202020202F2F20466F6C6420636F6D6D656E74732C2066696E64206669727374206C6576656C206368696C6472656E20616E642075706461746520746F67676C6520627574746F6E730A202020202020202020202020636F';
wwv_flow_api.g_varchar2_table(272) := '6D6D656E744C6973742E66696E6428272E636F6D6D656E7427292E72656D6F7665436C617373282776697369626C6527293B0A202020202020202020202020636F6D6D656E744C6973742E6368696C6472656E28272E636F6D6D656E7427292E65616368';
wwv_flow_api.g_varchar2_table(273) := '2866756E6374696F6E28696E6465782C20656C29207B0A2020202020202020202020202020202073656C662E757064617465546F67676C65416C6C427574746F6E282428656C29293B0A2020202020202020202020207D293B0A20202020202020207D2C';
wwv_flow_api.g_varchar2_table(274) := '0A0A2020202020202020736F7274436F6D6D656E74733A2066756E6374696F6E2028636F6D6D656E74732C20736F72744B657929207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A2020202020202020202020202F2F20';
wwv_flow_api.g_varchar2_table(275) := '536F727420627920706F70756C61726974790A202020202020202020202020696628736F72744B6579203D3D2027706F70756C61726974792729207B0A20202020202020202020202020202020636F6D6D656E74732E736F72742866756E6374696F6E28';
wwv_flow_api.g_varchar2_table(276) := '636F6D6D656E74412C20636F6D6D656E744229207B0A202020202020202020202020202020202020202076617220706F696E74734F6641203D20636F6D6D656E74412E6368696C64732E6C656E6774683B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(277) := '202076617220706F696E74734F6642203D20636F6D6D656E74422E6368696C64732E6C656E6774683B0A0A202020202020202020202020202020202020202069662873656C662E6F7074696F6E732E656E61626C655570766F74696E6729207B0A202020';
wwv_flow_api.g_varchar2_table(278) := '202020202020202020202020202020202020202020706F696E74734F6641202B3D20636F6D6D656E74412E7570766F7465436F756E743B0A202020202020202020202020202020202020202020202020706F696E74734F6642202B3D20636F6D6D656E74';
wwv_flow_api.g_varchar2_table(279) := '422E7570766F7465436F756E743B0A20202020202020202020202020202020202020207D0A0A2020202020202020202020202020202020202020696628706F696E74734F664220213D20706F696E74734F664129207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(280) := '202020202020202020202072657475726E20706F696E74734F6642202D20706F696E74734F66413B0A0A20202020202020202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020202020202F2F205265';
wwv_flow_api.g_varchar2_table(281) := '7475726E206E6577657220696620706F70756C6172697479206973207468652073616D650A202020202020202020202020202020202020202020202020766172206372656174656441203D206E6577204461746528636F6D6D656E74412E637265617465';
wwv_flow_api.g_varchar2_table(282) := '64292E67657454696D6528293B0A202020202020202020202020202020202020202020202020766172206372656174656442203D206E6577204461746528636F6D6D656E74422E63726561746564292E67657454696D6528293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(283) := '20202020202020202020202020202072657475726E206372656174656442202D2063726561746564413B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D293B0A0A2020202020202020202020202F2F';
wwv_flow_api.g_varchar2_table(284) := '20536F727420627920646174650A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020636F6D6D656E74732E736F72742866756E6374696F6E28636F6D6D656E74412C20636F6D6D656E744229207B0A20202020';
wwv_flow_api.g_varchar2_table(285) := '20202020202020202020202020202020766172206372656174656441203D206E6577204461746528636F6D6D656E74412E63726561746564292E67657454696D6528293B0A20202020202020202020202020202020202020207661722063726561746564';
wwv_flow_api.g_varchar2_table(286) := '42203D206E6577204461746528636F6D6D656E74422E63726561746564292E67657454696D6528293B0A2020202020202020202020202020202020202020696628736F72744B6579203D3D20276F6C646573742729207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(287) := '20202020202020202020202072657475726E206372656174656441202D2063726561746564423B0A20202020202020202020202020202020202020207D20656C7365207B0A20202020202020202020202020202020202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(288) := '6372656174656442202D2063726561746564413B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020736F72';
wwv_flow_api.g_varchar2_table(289) := '74416E645265417272616E6765436F6D6D656E74733A2066756E6374696F6E28736F72744B657929207B0A20202020202020202020202076617220636F6D6D656E744C697374203D20746869732E24656C2E66696E64282723636F6D6D656E742D6C6973';
wwv_flow_api.g_varchar2_table(290) := '7427293B0A0A2020202020202020202020202F2F20476574206D61696E206C6576656C20636F6D6D656E74730A202020202020202020202020766172206D61696E4C6576656C436F6D6D656E7473203D20746869732E676574436F6D6D656E747328292E';
wwv_flow_api.g_varchar2_table(291) := '66696C7465722866756E6374696F6E28636F6D6D656E744D6F64656C297B72657475726E2021636F6D6D656E744D6F64656C2E706172656E747D293B0A202020202020202020202020746869732E736F7274436F6D6D656E7473286D61696E4C6576656C';
wwv_flow_api.g_varchar2_table(292) := '436F6D6D656E74732C20736F72744B6579293B0A0A2020202020202020202020202F2F205265617272616E676520746865206D61696E206C6576656C20636F6D6D656E74730A20202020202020202020202024286D61696E4C6576656C436F6D6D656E74';
wwv_flow_api.g_varchar2_table(293) := '73292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E744D6F64656C29207B0A2020202020202020202020202020202076617220636F6D6D656E74456C203D20636F6D6D656E744C6973742E66696E6428273E206C692E636F6D6D65';
wwv_flow_api.g_varchar2_table(294) := '6E745B646174612D69643D272B636F6D6D656E744D6F64656C2E69642B275D27293B0A20202020202020202020202020202020636F6D6D656E744C6973742E617070656E6428636F6D6D656E74456C293B0A2020202020202020202020207D293B0A2020';
wwv_flow_api.g_varchar2_table(295) := '2020202020207D2C0A0A202020202020202073686F77416374697665536F72743A2066756E6374696F6E2829207B0A20202020202020202020202076617220616374697665456C656D656E7473203D20746869732E24656C2E66696E6428272E6E617669';
wwv_flow_api.g_varchar2_table(296) := '676174696F6E206C695B646174612D736F72742D6B65793D2227202B20746869732E63757272656E74536F72744B6579202B2027225D27293B0A0A2020202020202020202020202F2F20496E6469636174652061637469766520736F72740A2020202020';
wwv_flow_api.g_varchar2_table(297) := '20202020202020746869732E24656C2E66696E6428272E6E617669676174696F6E206C6927292E72656D6F7665436C617373282761637469766527293B0A202020202020202020202020616374697665456C656D656E74732E616464436C617373282761';
wwv_flow_api.g_varchar2_table(298) := '637469766527293B0A0A2020202020202020202020202F2F20557064617465207469746C6520666F722064726F70646F776E0A202020202020202020202020766172207469746C65456C203D20746869732E24656C2E66696E6428272E6E617669676174';
wwv_flow_api.g_varchar2_table(299) := '696F6E202E7469746C6527293B0A202020202020202020202020696628746869732E63757272656E74536F72744B657920213D20276174746163686D656E74732729207B0A202020202020202020202020202020207469746C65456C2E616464436C6173';
wwv_flow_api.g_varchar2_table(300) := '73282761637469766527293B0A202020202020202020202020202020207469746C65456C2E66696E64282768656164657227292E68746D6C28616374697665456C656D656E74732E666972737428292E68746D6C2829293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(301) := '20207D20656C7365207B0A202020202020202020202020202020207661722064656661756C7444726F70646F776E456C203D20746869732E24656C2E66696E6428272E6E617669676174696F6E20756C2E64726F70646F776E27292E6368696C6472656E';
wwv_flow_api.g_varchar2_table(302) := '28292E666972737428293B0A202020202020202020202020202020207469746C65456C2E66696E64282768656164657227292E68746D6C2864656661756C7444726F70646F776E456C2E68746D6C2829293B0A202020202020202020202020207D0A0A20';
wwv_flow_api.g_varchar2_table(303) := '20202020202020202020202F2F2053686F772061637469766520636F6E7461696E65720A202020202020202020202020746869732E73686F77416374697665436F6E7461696E657228293B0A20202020202020207D2C0A0A2020202020202020666F7263';
wwv_flow_api.g_varchar2_table(304) := '65526573706F6E736976653A2066756E6374696F6E2829207B0A202020202020202020202020746869732E24656C2E616464436C6173732827726573706F6E7369766527293B0A20202020202020207D2C0A0A20202020202020202F2F204576656E7420';
wwv_flow_api.g_varchar2_table(305) := '68616E646C6572730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A2020202020202020636C6F736544726F70646F776E733A2066756E6374696F6E2829207B0A202020202020202020202020746869732E24656C2E66696E642827';
wwv_flow_api.g_varchar2_table(306) := '2E64726F70646F776E27292E6869646528293B0A20202020202020207D2C0A0A2020202020202020707265536176655061737465644174746163686D656E74733A2066756E6374696F6E28657629207B0A20202020202020202020202076617220636C69';
wwv_flow_api.g_varchar2_table(307) := '70626F61726444617461203D2065762E6F726967696E616C4576656E742E636C6970626F617264446174613B0A2020202020202020202020207661722066696C6573203D20636C6970626F617264446174612E66696C65733B0A0A202020202020202020';
wwv_flow_api.g_varchar2_table(308) := '2020202F2F2042726F7773657273206F6E6C7920737570706F72742070617374696E67206F6E652066696C650A20202020202020202020202069662866696C65732026262066696C65732E6C656E677468203D3D203129207B0A0A202020202020202020';
wwv_flow_api.g_varchar2_table(309) := '202020202020202F2F2053656C65637420636F727265637420636F6D6D656E74696E67206669656C640A2020202020202020202020202020202076617220636F6D6D656E74696E674669656C643B0A202020202020202020202020202020207661722070';
wwv_flow_api.g_varchar2_table(310) := '6172656E74436F6D6D656E74696E674669656C64203D20242865762E746172676574292E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B200A20202020202020202020202020202020696628706172656E74';
wwv_flow_api.g_varchar2_table(311) := '436F6D6D656E74696E674669656C642E6C656E67746829207B0A2020202020202020202020202020202020202020636F6D6D656E74696E674669656C64203D20706172656E74436F6D6D656E74696E674669656C643B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(312) := '2020207D0A0A20202020202020202020202020202020746869732E707265536176654174746163686D656E74732866696C65732C20636F6D6D656E74696E674669656C64293B0A2020202020202020202020202020202065762E70726576656E74446566';
wwv_flow_api.g_varchar2_table(313) := '61756C7428293B0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020736176654F6E4B6579646F776E3A2066756E6374696F6E28657629207B0A2020202020202020202020202F2F205361766520636F6D6D656E7420';
wwv_flow_api.g_varchar2_table(314) := '6F6E20636D642F6374726C202B20656E7465720A20202020202020202020202069662865762E6B6579436F6465203D3D20313329207B0A20202020202020202020202020202020766172206D6574614B6579203D2065762E6D6574614B6579207C7C2065';
wwv_flow_api.g_varchar2_table(315) := '762E6374726C4B65793B0A20202020202020202020202020202020696628746869732E6F7074696F6E732E706F7374436F6D6D656E744F6E456E746572207C7C206D6574614B657929C2A07B0A2020202020202020202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(316) := '20656C203D20242865762E63757272656E74546172676574293B0A2020202020202020202020202020202020202020656C2E7369626C696E677328272E636F6E74726F6C2D726F7727292E66696E6428272E7361766527292E747269676765722827636C';
wwv_flow_api.g_varchar2_table(317) := '69636B27293B0A202020202020202020202020202020202020202065762E73746F7050726F7061676174696F6E28293B0A202020202020202020202020202020202020202065762E70726576656E7444656661756C7428293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(318) := '2020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020736176654564697461626C65436F6E74656E743A2066756E6374696F6E28657629207B0A20202020202020202020202076617220656C203D2024';
wwv_flow_api.g_varchar2_table(319) := '2865762E63757272656E74546172676574293B0A202020202020202020202020656C2E6461746128276265666F7265272C20656C2E68746D6C2829293B0A20202020202020207D2C0A0A2020202020202020636865636B4564697461626C65436F6E7465';
wwv_flow_api.g_varchar2_table(320) := '6E74466F724368616E67653A2066756E6374696F6E28657629207B0A20202020202020202020202076617220656C203D20242865762E63757272656E74546172676574293B0A0A2020202020202020202020202F2F20466978206A71756572792D746578';
wwv_flow_api.g_varchar2_table(321) := '74636F6D706C657465206F6E2049452C20656D7074792074657874206E6F6465732077696C6C20627265616B20757020746865206175746F636F6D706C65746520666561747572650A2020202020202020202020202428656C5B305D2E6368696C644E6F';
wwv_flow_api.g_varchar2_table(322) := '646573292E656163682866756E6374696F6E2829207B0A20202020202020202020202020202020696628746869732E6E6F646554797065203D3D204E6F64652E544558545F4E4F444520262620746869732E6C656E677468203D3D203020262620746869';
wwv_flow_api.g_varchar2_table(323) := '732E72656D6F76654E6F64652920746869732E72656D6F76654E6F646528293B0A2020202020202020202020207D293B0A0A20202020202020202020202069662028656C2E6461746128276265666F7265272920213D20656C2E68746D6C282929207B0A';
wwv_flow_api.g_varchar2_table(324) := '20202020202020202020202020202020656C2E6461746128276265666F7265272C20656C2E68746D6C2829293B0A20202020202020202020202020202020656C2E7472696767657228276368616E676527293B0A2020202020202020202020207D0A2020';
wwv_flow_api.g_varchar2_table(325) := '2020202020207D2C0A0A20202020202020206E617669676174696F6E456C656D656E74436C69636B65643A2066756E6374696F6E28657629207B0A202020202020202020202020766172206E617669676174696F6E456C203D20242865762E6375727265';
wwv_flow_api.g_varchar2_table(326) := '6E74546172676574293B0A20202020202020202020202076617220736F72744B6579203D206E617669676174696F6E456C2E6461746128292E736F72744B65793B0A0A2020202020202020202020202F2F20536F72742074686520636F6D6D656E747320';
wwv_flow_api.g_varchar2_table(327) := '6966206E65636573736172790A202020202020202020202020696628736F72744B6579203D3D20276174746163686D656E74732729207B0A20202020202020202020202020202020746869732E6372656174654174746163686D656E747328293B0A2020';
wwv_flow_api.g_varchar2_table(328) := '202020202020202020207D20656C7365207B0A20202020202020202020202020202020746869732E736F7274416E645265417272616E6765436F6D6D656E747328736F72744B6579293B0A2020202020202020202020207D0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(329) := '20202F2F2053617665207468652063757272656E7420736F7274206B65790A202020202020202020202020746869732E63757272656E74536F72744B6579203D20736F72744B65793B0A202020202020202020202020746869732E73686F774163746976';
wwv_flow_api.g_varchar2_table(330) := '65536F727428293B0A20202020202020207D2C0A0A2020202020202020746F67676C654E617669676174696F6E44726F70646F776E3A2066756E6374696F6E28657629207B0A2020202020202020202020202F2F2050726576656E7420636C6F73696E67';
wwv_flow_api.g_varchar2_table(331) := '20696D6D6564696174656C790A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0A0A2020202020202020202020207661722064726F70646F776E203D20242865762E63757272656E74546172676574292E66696E6428';
wwv_flow_api.g_varchar2_table(332) := '277E202E64726F70646F776E27293B0A20202020202020202020202064726F70646F776E2E746F67676C6528293B0A20202020202020207D2C0A0A202020202020202073686F774D61696E436F6D6D656E74696E674669656C643A2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(333) := '28657629207B0A202020202020202020202020766172206D61696E5465787461726561203D20242865762E63757272656E74546172676574293B0A2020202020202020202020206D61696E54657874617265612E7369626C696E677328272E636F6E7472';
wwv_flow_api.g_varchar2_table(334) := '6F6C2D726F7727292E73686F7728293B0A2020202020202020202020206D61696E54657874617265612E706172656E7428292E66696E6428272E636C6F736527292E73686F7728293B0A2020202020202020202020206D61696E54657874617265612E70';
wwv_flow_api.g_varchar2_table(335) := '6172656E7428292E66696E6428272E75706C6F61642E696E6C696E652D627574746F6E27292E6869646528293B0A2020202020202020202020206D61696E54657874617265612E666F63757328293B0A20202020202020207D2C0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(336) := '686964654D61696E436F6D6D656E74696E674669656C643A2066756E6374696F6E28657629207B0A20202020202020202020202076617220636C6F7365427574746F6E203D20242865762E63757272656E74546172676574293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(337) := '20202076617220636F6D6D656E74696E674669656C64203D20746869732E24656C2E66696E6428272E636F6D6D656E74696E672D6669656C642E6D61696E27293B0A202020202020202020202020766172206D61696E5465787461726561203D20636F6D';
wwv_flow_api.g_varchar2_table(338) := '6D656E74696E674669656C642E66696E6428272E746578746172656127293B0A202020202020202020202020766172206D61696E436F6E74726F6C526F77203D20636F6D6D656E74696E674669656C642E66696E6428272E636F6E74726F6C2D726F7727';
wwv_flow_api.g_varchar2_table(339) := '293B0A0A2020202020202020202020202F2F20436C656172207465787420617265610A202020202020202020202020746869732E636C6561725465787461726561286D61696E5465787461726561293B0A0A2020202020202020202020202F2F20436C65';
wwv_flow_api.g_varchar2_table(340) := '6172206174746163686D656E74730A202020202020202020202020636F6D6D656E74696E674669656C642E66696E6428272E6174746163686D656E747327292E656D70747928293B0A0A2020202020202020202020202F2F20546F67676C652073617665';
wwv_flow_api.g_varchar2_table(341) := '20627574746F6E0A202020202020202020202020746869732E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64293B0A0A2020202020202020202020202F2F2041646A757374206865696768740A20202020202020202020';
wwv_flow_api.g_varchar2_table(342) := '2020746869732E61646A7573745465787461726561486569676874286D61696E54657874617265612C2066616C7365293B0A0A2020202020202020202020206D61696E436F6E74726F6C526F772E6869646528293B0A202020202020202020202020636C';
wwv_flow_api.g_varchar2_table(343) := '6F7365427574746F6E2E6869646528293B0A2020202020202020202020206D61696E54657874617265612E706172656E7428292E66696E6428272E75706C6F61642E696E6C696E652D627574746F6E27292E73686F7728293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(344) := '20206D61696E54657874617265612E626C757228293B0A20202020202020207D2C0A0A2020202020202020696E63726561736554657874617265614865696768743A2066756E6374696F6E28657629207B0A202020202020202020202020766172207465';
wwv_flow_api.g_varchar2_table(345) := '787461726561203D20242865762E63757272656E74546172676574293B0A202020202020202020202020746869732E61646A75737454657874617265614865696768742874657874617265612C2074727565293B0A20202020202020207D2C0A0A202020';
wwv_flow_api.g_varchar2_table(346) := '20202020207465787461726561436F6E74656E744368616E6765643A2066756E6374696F6E28657629207B0A202020202020202020202020766172207465787461726561203D20242865762E63757272656E74546172676574293B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(347) := '20202020202F2F2055706461746520706172656E74206964206966207265706C792D746F20746167207761732072656D6F7665640A2020202020202020202020206966282174657874617265612E66696E6428272E7265706C792D746F2E74616727292E';
wwv_flow_api.g_varchar2_table(348) := '6C656E67746829207B0A2020202020202020202020202020202076617220636F6D6D656E744964203D2074657874617265612E617474722827646174612D636F6D6D656E7427293B0A0A202020202020202020202020202020202F2F20436173653A2065';
wwv_flow_api.g_varchar2_table(349) := '646974696E6720636F6D6D656E740A20202020202020202020202020202020696628636F6D6D656E74496429207B0A202020202020202020202020202020202020202076617220706172656E74436F6D6D656E7473203D2074657874617265612E706172';
wwv_flow_api.g_varchar2_table(350) := '656E747328276C692E636F6D6D656E7427293B0A2020202020202020202020202020202020202020696628706172656E74436F6D6D656E74732E6C656E677468203E203129207B0A20202020202020202020202020202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(351) := '706172656E744964203D20706172656E74436F6D6D656E74732E6C61737428292E646174612827696427293B0A20202020202020202020202020202020202020202020202074657874617265612E617474722827646174612D706172656E74272C207061';
wwv_flow_api.g_varchar2_table(352) := '72656E744964293B0A20202020202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F20436173653A206E657720636F6D6D656E740A202020202020202020202020202020207D20656C7365207B0A202020202020';
wwv_flow_api.g_varchar2_table(353) := '202020202020202020202020202076617220706172656E744964203D2074657874617265612E706172656E747328276C692E636F6D6D656E7427292E6C61737428292E646174612827696427293B0A202020202020202020202020202020202020202074';
wwv_flow_api.g_varchar2_table(354) := '657874617265612E617474722827646174612D706172656E74272C20706172656E744964293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F204D6F766520636C6F7365206275';
wwv_flow_api.g_varchar2_table(355) := '74746F6E206966207363726F6C6C6261722069732076697369626C650A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D2074657874617265612E706172656E747328272E636F6D6D656E74696E672D6669656C642729';
wwv_flow_api.g_varchar2_table(356) := '2E666972737428293B0A20202020202020202020202069662874657874617265615B305D2E7363726F6C6C486569676874203E2074657874617265612E6F75746572486569676874282929207B0A20202020202020202020202020202020636F6D6D656E';
wwv_flow_api.g_varchar2_table(357) := '74696E674669656C642E616464436C6173732827636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C6527293B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020636F6D6D656E74696E674669';
wwv_flow_api.g_varchar2_table(358) := '656C642E72656D6F7665436C6173732827636F6D6D656E74696E672D6669656C642D7363726F6C6C61626C6527293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20436865636B206966207361766520627574746F6E206E';
wwv_flow_api.g_varchar2_table(359) := '6565647320746F20626520656E61626C65640A202020202020202020202020746869732E746F67676C6553617665427574746F6E28636F6D6D656E74696E674669656C64293B0A20202020202020207D2C0A0A2020202020202020746F67676C65536176';
wwv_flow_api.g_varchar2_table(360) := '65427574746F6E3A2066756E6374696F6E28636F6D6D656E74696E674669656C6429207B0A202020202020202020202020766172207465787461726561203D20636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127293B0A20';
wwv_flow_api.g_varchar2_table(361) := '20202020202020202020207661722073617665427574746F6E203D2074657874617265612E7369626C696E677328272E636F6E74726F6C2D726F7727292E66696E6428272E7361766527293B0A0A20202020202020202020202076617220636F6E74656E';
wwv_flow_api.g_varchar2_table(362) := '74203D20746869732E6765745465787461726561436F6E74656E742874657874617265612C2074727565293B0A202020202020202020202020766172206174746163686D656E7473203D20746869732E6765744174746163686D656E747346726F6D436F';
wwv_flow_api.g_varchar2_table(363) := '6D6D656E74696E674669656C6428636F6D6D656E74696E674669656C64293B0A20202020202020202020202076617220656E61626C65643B0A0A2020202020202020202020202F2F20436173653A206578697374696E6720636F6D6D656E740A20202020';
wwv_flow_api.g_varchar2_table(364) := '2020202020202020696628636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B74657874617265612E617474722827646174612D636F6D6D656E7427295D29207B0A0A202020202020202020202020202020202F2F204361';
wwv_flow_api.g_varchar2_table(365) := '73653A20706172656E74206368616E6765640A2020202020202020202020202020202076617220636F6E74656E744368616E676564203D20636F6E74656E7420213D20636F6D6D656E744D6F64656C2E636F6E74656E743B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(366) := '202020202076617220706172656E7446726F6D4D6F64656C3B0A20202020202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A2020202020202020202020202020202020202020706172656E7446726F6D4D6F';
wwv_flow_api.g_varchar2_table(367) := '64656C203D20636F6D6D656E744D6F64656C2E706172656E742E746F537472696E6728293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F20436173653A20706172656E74206368616E6765640A202020';
wwv_flow_api.g_varchar2_table(368) := '2020202020202020202020202076617220706172656E744368616E676564203D2074657874617265612E617474722827646174612D706172656E74272920213D20706172656E7446726F6D4D6F64656C3B0A0A202020202020202020202020202020202F';
wwv_flow_api.g_varchar2_table(369) := '2F20436173653A206174746163686D656E7473206368616E6765640A20202020202020202020202020202020766172206174746163686D656E74734368616E676564203D2066616C73653B0A20202020202020202020202020202020696628746869732E';
wwv_flow_api.g_varchar2_table(370) := '6F7074696F6E732E656E61626C654174746163686D656E747329207B0A20202020202020202020202020202020202020207661722073617665644174746163686D656E74496473203D20636F6D6D656E744D6F64656C2E6174746163686D656E74732E6D';
wwv_flow_api.g_varchar2_table(371) := '61702866756E6374696F6E286174746163686D656E74297B72657475726E206174746163686D656E742E69647D293B0A20202020202020202020202020202020202020207661722063757272656E744174746163686D656E74496473203D206174746163';
wwv_flow_api.g_varchar2_table(372) := '686D656E74732E6D61702866756E6374696F6E286174746163686D656E74297B72657475726E206174746163686D656E742E69647D293B0A20202020202020202020202020202020202020206174746163686D656E74734368616E676564203D20217468';
wwv_flow_api.g_varchar2_table(373) := '69732E617265417272617973457175616C2873617665644174746163686D656E744964732C2063757272656E744174746163686D656E74496473293B0A202020202020202020202020202020207D0A0A20202020202020202020202020202020656E6162';
wwv_flow_api.g_varchar2_table(374) := '6C6564203D20636F6E74656E744368616E676564207C7C20706172656E744368616E676564207C7C206174746163686D656E74734368616E6765643B0A0A2020202020202020202020202F2F20436173653A206E657720636F6D6D656E740A2020202020';
wwv_flow_api.g_varchar2_table(375) := '202020202020207D20656C7365207B0A20202020202020202020202020202020656E61626C6564203D20426F6F6C65616E28636F6E74656E742E6C656E67746829207C7C20426F6F6C65616E286174746163686D656E74732E6C656E677468293B0A2020';
wwv_flow_api.g_varchar2_table(376) := '202020202020202020207D0A0A20202020202020202020202073617665427574746F6E2E746F67676C65436C6173732827656E61626C6564272C20656E61626C6564293B0A20202020202020207D2C0A0A202020202020202072656D6F7665436F6D6D65';
wwv_flow_api.g_varchar2_table(377) := '6E74696E674669656C643A2066756E6374696F6E28657629207B0A20202020202020202020202076617220636C6F7365427574746F6E203D20242865762E63757272656E74546172676574293B0A0A2020202020202020202020202F2F2052656D6F7665';
wwv_flow_api.g_varchar2_table(378) := '206564697420636C6173732066726F6D20636F6D6D656E742069662075736572207761732065646974696E672074686520636F6D6D656E740A202020202020202020202020766172207465787461726561203D20636C6F7365427574746F6E2E7369626C';
wwv_flow_api.g_varchar2_table(379) := '696E677328272E746578746172656127293B0A20202020202020202020202069662874657874617265612E617474722827646174612D636F6D6D656E74272929207B0A20202020202020202020202020202020636C6F7365427574746F6E2E706172656E';
wwv_flow_api.g_varchar2_table(380) := '747328276C692E636F6D6D656E7427292E666972737428292E72656D6F7665436C61737328276564697427293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2052656D6F766520746865206669656C640A20202020202020';
wwv_flow_api.g_varchar2_table(381) := '202020202076617220636F6D6D656E74696E674669656C64203D20636C6F7365427574746F6E2E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E666972737428293B0A202020202020202020202020636F6D6D656E74696E6746';
wwv_flow_api.g_varchar2_table(382) := '69656C642E72656D6F766528293B0A20202020202020207D2C0A0A2020202020202020706F7374436F6D6D656E743A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A2020202020202020';
wwv_flow_api.g_varchar2_table(383) := '202020207661722073656E64427574746F6E203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D2073656E64427574746F6E2E706172656E747328272E636F6D';
wwv_flow_api.g_varchar2_table(384) := '6D656E74696E672D6669656C6427292E666972737428293B0A0A2020202020202020202020202F2F2053657420627574746F6E20737461746520746F206C6F6164696E670A202020202020202020202020746869732E736574427574746F6E5374617465';
wwv_flow_api.g_varchar2_table(385) := '2873656E64427574746F6E2C2066616C73652C2074727565293B0A0A2020202020202020202020202F2F2043726561746520636F6D6D656E74204A534F4E0A20202020202020202020202076617220636F6D6D656E744A534F4E203D20746869732E6372';
wwv_flow_api.g_varchar2_table(386) := '65617465436F6D6D656E744A534F4E28636F6D6D656E74696E674669656C64293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E670A202020202020202020202020636F6D6D656E744A534F4E203D20746869732E617070';
wwv_flow_api.g_varchar2_table(387) := '6C7945787465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(388) := '73656C662E637265617465436F6D6D656E7428636F6D6D656E744A534F4E293B0A20202020202020202020202020202020636F6D6D656E74696E674669656C642E66696E6428272E636C6F736527292E747269676765722827636C69636B27293B0A0A20';
wwv_flow_api.g_varchar2_table(389) := '2020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652873656E64427574746F6E2C2066616C73652C2066616C7365293B0A';
wwv_flow_api.g_varchar2_table(390) := '2020202020202020202020207D3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020';
wwv_flow_api.g_varchar2_table(391) := '202020202020202073656C662E736574427574746F6E53746174652873656E64427574746F6E2C20747275652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020746869732E6F7074696F6E732E706F737443';
wwv_flow_api.g_varchar2_table(392) := '6F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A20202020';
wwv_flow_api.g_varchar2_table(393) := '202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E637265617465436F6D6D656E744D6F64656C28636F6D6D656E744A534F4E293B0A202020202020202020202020746869732E616464436F6D6D656E74546F446174614D6F';
wwv_flow_api.g_varchar2_table(394) := '64656C28636F6D6D656E744D6F64656C293B0A0A2020202020202020202020202F2F2041646420636F6D6D656E7420656C656D656E740A20202020202020202020202076617220636F6D6D656E744C697374203D20746869732E24656C2E66696E642827';
wwv_flow_api.g_varchar2_table(395) := '23636F6D6D656E742D6C69737427293B0A2020202020202020202020207661722070726570656E64436F6D6D656E74203D20746869732E63757272656E74536F72744B6579203D3D20276E6577657374273B0A202020202020202020202020746869732E';
wwv_flow_api.g_varchar2_table(396) := '616464436F6D6D656E7428636F6D6D656E744D6F64656C2C20636F6D6D656E744C6973742C2070726570656E64436F6D6D656E74293B0A0A202020202020202020202020696628746869732E63757272656E74536F72744B6579203D3D20276174746163';
wwv_flow_api.g_varchar2_table(397) := '686D656E74732720262620636F6D6D656E744D6F64656C2E6861734174746163686D656E7473282929207B0A20202020202020202020202020202020746869732E6164644174746163686D656E7428636F6D6D656E744D6F64656C293B0A202020202020';
wwv_flow_api.g_varchar2_table(398) := '2020202020207D0A20202020202020207D2C0A0A2020202020202020707574436F6D6D656E743A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(399) := '73617665427574746F6E203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D2073617665427574746F6E2E706172656E747328272E636F6D6D656E74696E672D';
wwv_flow_api.g_varchar2_table(400) := '6669656C6427292E666972737428293B0A202020202020202020202020766172207465787461726561203D20636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127293B0A0A2020202020202020202020202F2F205365742062';
wwv_flow_api.g_varchar2_table(401) := '7574746F6E20737461746520746F206C6F6164696E670A202020202020202020202020746869732E736574427574746F6E53746174652873617665427574746F6E2C2066616C73652C2074727565293B0A0A2020202020202020202020202F2F20557365';
wwv_flow_api.g_varchar2_table(402) := '206120636C6F6E65206F6620746865206578697374696E67206D6F64656C20616E642075706461746520746865206D6F64656C2061667465722073756363657366756C6C207570646174650A20202020202020202020202076617220636F6D6D656E744A';
wwv_flow_api.g_varchar2_table(403) := '534F4E203D2020242E657874656E64287B7D2C20746869732E636F6D6D656E7473427949645B74657874617265612E617474722827646174612D636F6D6D656E7427295D293B0A202020202020202020202020242E657874656E6428636F6D6D656E744A';
wwv_flow_api.g_varchar2_table(404) := '534F4E2C207B0A20202020202020202020202020202020706172656E743A2074657874617265612E617474722827646174612D706172656E742729207C7C206E756C6C2C0A20202020202020202020202020202020636F6E74656E743A20746869732E67';
wwv_flow_api.g_varchar2_table(405) := '65745465787461726561436F6E74656E74287465787461726561292C0A2020202020202020202020202020202070696E67733A20746869732E67657450696E6773287465787461726561292C0A202020202020202020202020202020206D6F6469666965';
wwv_flow_api.g_varchar2_table(406) := '643A206E6577204461746528292E67657454696D6528292C0A202020202020202020202020202020206174746163686D656E74733A20746869732E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C6428636F6D6D656E74';
wwv_flow_api.g_varchar2_table(407) := '696E674669656C64290A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E670A202020202020202020202020636F6D6D656E744A534F4E203D20746869732E6170706C7945787465726E';
wwv_flow_api.g_varchar2_table(408) := '616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A202020202020202020202020202020202F2F20546865206F';
wwv_flow_api.g_varchar2_table(409) := '757465726D6F737420706172656E742063616E206E6F74206265206368616E6765642062792065646974696E672074686520636F6D6D656E7420736F20746865206368696C64732061727261790A202020202020202020202020202020202F2F206F6620';
wwv_flow_api.g_varchar2_table(410) := '706172656E7420646F6573206E6F74207265717569726520616E207570646174650A0A2020202020202020202020202020202076617220636F6D6D656E744D6F64656C203D2073656C662E637265617465436F6D6D656E744D6F64656C28636F6D6D656E';
wwv_flow_api.g_varchar2_table(411) := '744A534F4E293B0A0A202020202020202020202020202020202F2F2044656C657465206368696C64732061727261792066726F6D206E657720636F6D6D656E74206D6F64656C2073696E636520697420646F65736E2774206E65656420616E2075706461';
wwv_flow_api.g_varchar2_table(412) := '74650A2020202020202020202020202020202064656C65746520636F6D6D656E744D6F64656C5B276368696C6473275D3B0A2020202020202020202020202020202073656C662E757064617465436F6D6D656E744D6F64656C28636F6D6D656E744D6F64';
wwv_flow_api.g_varchar2_table(413) := '656C293B0A0A202020202020202020202020202020202F2F20436C6F7365207468652065646974696E67206669656C640A20202020202020202020202020202020636F6D6D656E74696E674669656C642E66696E6428272E636C6F736527292E74726967';
wwv_flow_api.g_varchar2_table(414) := '6765722827636C69636B27293B0A0A202020202020202020202020202020202F2F2052652D72656E6465722074686520636F6D6D656E740A2020202020202020202020202020202073656C662E726552656E646572436F6D6D656E7428636F6D6D656E74';
wwv_flow_api.g_varchar2_table(415) := '4D6F64656C2E6964293B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652873617665427574746F6E2C206661';
wwv_flow_api.g_varchar2_table(416) := '6C73652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073';
wwv_flow_api.g_varchar2_table(417) := '746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652873617665427574746F6E2C20747275652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020746869732E';
wwv_flow_api.g_varchar2_table(418) := '6F7074696F6E732E707574436F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A202020202020202064656C657465436F6D6D656E743A2066756E6374696F6E28657629207B0A20';
wwv_flow_api.g_varchar2_table(419) := '20202020202020202020207661722073656C66203D20746869733B0A2020202020202020202020207661722064656C657465427574746F6E203D20242865762E63757272656E74546172676574293B0A20202020202020202020202076617220636F6D6D';
wwv_flow_api.g_varchar2_table(420) := '656E74456C203D2064656C657465427574746F6E2E706172656E747328272E636F6D6D656E7427292E666972737428293B0A20202020202020202020202076617220636F6D6D656E744A534F4E203D2020242E657874656E64287B7D2C20746869732E63';
wwv_flow_api.g_varchar2_table(421) := '6F6D6D656E7473427949645B636F6D6D656E74456C2E617474722827646174612D696427295D293B0A20202020202020202020202076617220636F6D6D656E744964203D20636F6D6D656E744A534F4E2E69643B0A202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(422) := '20706172656E744964203D20636F6D6D656E744A534F4E2E706172656E743B0A0A2020202020202020202020202F2F2053657420627574746F6E20737461746520746F206C6F6164696E670A202020202020202020202020746869732E73657442757474';
wwv_flow_api.g_varchar2_table(423) := '6F6E53746174652864656C657465427574746F6E2C2066616C73652C2074727565293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E670A202020202020202020202020636F6D6D656E744A534F4E203D20746869732E61';
wwv_flow_api.g_varchar2_table(424) := '70706C7945787465726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E2829207B0A2020202020202020202020202020202073656C662E72656D6F';
wwv_flow_api.g_varchar2_table(425) := '7665436F6D6D656E7428636F6D6D656E744964293B0A20202020202020202020202020202020696628706172656E744964292073656C662E726552656E646572436F6D6D656E74416374696F6E42617228706172656E744964293B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(426) := '2020202020202020202F2F20526573657420627574746F6E2073746174650A2020202020202020202020202020202073656C662E736574427574746F6E53746174652864656C657465427574746F6E2C2066616C73652C2066616C7365293B0A20202020';
wwv_flow_api.g_varchar2_table(427) := '20202020202020207D3B0A0A202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F20526573657420627574746F6E2073746174650A202020202020202020202020';
wwv_flow_api.g_varchar2_table(428) := '2020202073656C662E736574427574746F6E53746174652864656C657465427574746F6E2C20747275652C2066616C7365293B0A2020202020202020202020207D3B0A0A202020202020202020202020746869732E6F7074696F6E732E64656C65746543';
wwv_flow_api.g_varchar2_table(429) := '6F6D6D656E7428636F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A202020202020202068617368746167436C69636B65643A2066756E6374696F6E28657629207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(430) := '76617220656C203D20242865762E63757272656E74546172676574293B0A2020202020202020202020207661722076616C7565203D20656C2E617474722827646174612D76616C756527293B0A202020202020202020202020746869732E6F7074696F6E';
wwv_flow_api.g_varchar2_table(431) := '732E68617368746167436C69636B65642876616C7565293B0A20202020202020207D2C0A0A202020202020202070696E67436C69636B65643A2066756E6374696F6E28657629207B0A20202020202020202020202076617220656C203D20242865762E63';
wwv_flow_api.g_varchar2_table(432) := '757272656E74546172676574293B0A2020202020202020202020207661722076616C7565203D20656C2E617474722827646174612D76616C756527293B0A202020202020202020202020746869732E6F7074696F6E732E70696E67436C69636B65642876';
wwv_flow_api.g_varchar2_table(433) := '616C7565293B0A20202020202020207D2C0A0A202020202020202066696C65496E7075744368616E6765643A2066756E6374696F6E2865762C2066696C657329207B0A2020202020202020202020207661722066696C6573203D2065762E63757272656E';
wwv_flow_api.g_varchar2_table(434) := '745461726765742E66696C65733B0A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D20242865762E63757272656E74546172676574292E706172656E747328272E636F6D6D656E74696E672D6669656C6427292E6669';
wwv_flow_api.g_varchar2_table(435) := '72737428293B0A202020202020202020202020746869732E707265536176654174746163686D656E74732866696C65732C20636F6D6D656E74696E674669656C64293B0A20202020202020207D2C0A0A20202020202020207570766F7465436F6D6D656E';
wwv_flow_api.g_varchar2_table(436) := '743A2066756E6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A20202020202020202020202076617220636F6D6D656E74456C203D20242865762E63757272656E74546172676574292E706172656E';
wwv_flow_api.g_varchar2_table(437) := '747328276C692E636F6D6D656E7427292E666972737428293B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20636F6D6D656E74456C2E6461746128292E6D6F64656C3B0A0A2020202020202020202020202F2F20436865';
wwv_flow_api.g_varchar2_table(438) := '636B20776865746865722075736572207570766F7465642074686520636F6D6D656E74206F72207265766F6B656420746865207570766F74650A2020202020202020202020207661722070726576696F75735570766F7465436F756E74203D20636F6D6D';
wwv_flow_api.g_varchar2_table(439) := '656E744D6F64656C2E7570766F7465436F756E743B0A202020202020202020202020766172206E65775570766F7465436F756E743B0A202020202020202020202020696628636F6D6D656E744D6F64656C2E757365724861735570766F74656429207B0A';
wwv_flow_api.g_varchar2_table(440) := '202020202020202020202020202020206E65775570766F7465436F756E74203D2070726576696F75735570766F7465436F756E74202D20313B0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020206E65775570';
wwv_flow_api.g_varchar2_table(441) := '766F7465436F756E74203D2070726576696F75735570766F7465436F756E74202B20313B0A2020202020202020202020207D0A0A2020202020202020202020202F2F2053686F77206368616E67657320696D6D6564696174656C790A2020202020202020';
wwv_flow_api.g_varchar2_table(442) := '20202020636F6D6D656E744D6F64656C2E757365724861735570766F746564203D2021636F6D6D656E744D6F64656C2E757365724861735570766F7465643B0A202020202020202020202020636F6D6D656E744D6F64656C2E7570766F7465436F756E74';
wwv_flow_api.g_varchar2_table(443) := '203D206E65775570766F7465436F756E743B0A202020202020202020202020746869732E726552656E6465725570766F74657328636F6D6D656E744D6F64656C2E6964293B0A0A2020202020202020202020202F2F2052657665727365206D617070696E';
wwv_flow_api.g_varchar2_table(444) := '670A20202020202020202020202076617220636F6D6D656E744A534F4E203D20242E657874656E64287B7D2C20636F6D6D656E744D6F64656C293B0A202020202020202020202020636F6D6D656E744A534F4E203D20746869732E6170706C7945787465';
wwv_flow_api.g_varchar2_table(445) := '726E616C4D617070696E677328636F6D6D656E744A534F4E293B0A0A2020202020202020202020207661722073756363657373203D2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A2020202020202020202020202020202076617220636F';
wwv_flow_api.g_varchar2_table(446) := '6D6D656E744D6F64656C203D2073656C662E637265617465436F6D6D656E744D6F64656C28636F6D6D656E744A534F4E293B0A2020202020202020202020202020202073656C662E757064617465436F6D6D656E744D6F64656C28636F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(447) := '64656C293B0A2020202020202020202020202020202073656C662E726552656E6465725570766F74657328636F6D6D656E744D6F64656C2E6964293B0A2020202020202020202020207D3B0A0A202020202020202020202020766172206572726F72203D';
wwv_flow_api.g_varchar2_table(448) := '2066756E6374696F6E2829207B0A0A202020202020202020202020202020202F2F20526576657274206368616E6765730A20202020202020202020202020202020636F6D6D656E744D6F64656C2E757365724861735570766F746564203D2021636F6D6D';
wwv_flow_api.g_varchar2_table(449) := '656E744D6F64656C2E757365724861735570766F7465643B0A20202020202020202020202020202020636F6D6D656E744D6F64656C2E7570766F7465436F756E74203D2070726576696F75735570766F7465436F756E743B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(450) := '202020202073656C662E726552656E6465725570766F74657328636F6D6D656E744D6F64656C2E6964293B0A2020202020202020202020207D3B0A0A202020202020202020202020746869732E6F7074696F6E732E7570766F7465436F6D6D656E742863';
wwv_flow_api.g_varchar2_table(451) := '6F6D6D656E744A534F4E2C20737563636573732C206572726F72293B0A20202020202020207D2C0A0A2020202020202020746F67676C655265706C6965733A2066756E6374696F6E28657629207B0A20202020202020202020202076617220656C203D20';
wwv_flow_api.g_varchar2_table(452) := '242865762E63757272656E74546172676574293B0A202020202020202020202020656C2E7369626C696E677328272E746F67676C61626C652D7265706C7927292E746F67676C65436C617373282776697369626C6527293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(453) := '20746869732E736574546F67676C65416C6C427574746F6E5465787428656C2C2074727565293B0A20202020202020207D2C0A0A20202020202020207265706C79427574746F6E436C69636B65643A2066756E6374696F6E28657629207B0A2020202020';
wwv_flow_api.g_varchar2_table(454) := '20202020202020766172207265706C79427574746F6E203D20242865762E63757272656E74546172676574293B0A202020202020202020202020766172206F757465726D6F7374506172656E74203D207265706C79427574746F6E2E706172656E747328';
wwv_flow_api.g_varchar2_table(455) := '276C692E636F6D6D656E7427292E6C61737428293B0A20202020202020202020202076617220706172656E744964203D207265706C79427574746F6E2E706172656E747328272E636F6D6D656E7427292E666972737428292E6461746128292E69643B0A';
wwv_flow_api.g_varchar2_table(456) := '0A0A2020202020202020202020202F2F2052656D6F7665206578697374696E67206669656C640A202020202020202020202020766172207265706C794669656C64203D206F757465726D6F7374506172656E742E66696E6428272E6368696C642D636F6D';
wwv_flow_api.g_varchar2_table(457) := '6D656E7473203E202E636F6D6D656E74696E672D6669656C6427293B0A2020202020202020202020206966287265706C794669656C642E6C656E67746829207265706C794669656C642E72656D6F766528293B0A20202020202020202020202076617220';
wwv_flow_api.g_varchar2_table(458) := '70726576696F7573506172656E744964203D207265706C794669656C642E66696E6428272E746578746172656127292E617474722827646174612D706172656E7427293B0A0A2020202020202020202020202F2F2043726561746520746865207265706C';
wwv_flow_api.g_varchar2_table(459) := '79206669656C642028646F206E6F742072652D637265617465290A20202020202020202020202069662870726576696F7573506172656E74496420213D20706172656E74496429207B0A202020202020202020202020202020207265706C794669656C64';
wwv_flow_api.g_varchar2_table(460) := '203D20746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E7428706172656E744964293B0A202020202020202020202020202020206F757465726D6F7374506172656E742E66696E6428272E6368696C642D636F6D6D656E74';
wwv_flow_api.g_varchar2_table(461) := '7327292E617070656E64287265706C794669656C64293B0A0A202020202020202020202020202020202F2F204D6F766520637572736F7220746F20656E640A20202020202020202020202020202020766172207465787461726561203D207265706C7946';
wwv_flow_api.g_varchar2_table(462) := '69656C642E66696E6428272E746578746172656127293B0A20202020202020202020202020202020746869732E6D6F7665437572736F72546F456E64287465787461726561293B0A0A202020202020202020202020202020202F2F20456E737572652065';
wwv_flow_api.g_varchar2_table(463) := '6C656D656E742073746179732076697369626C650A20202020202020202020202020202020746869732E656E73757265456C656D656E74537461797356697369626C65287265706C794669656C64293B0A2020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(464) := '2020207D2C0A0A202020202020202065646974427574746F6E436C69636B65643A2066756E6374696F6E28657629207B0A2020202020202020202020207661722065646974427574746F6E203D20242865762E63757272656E74546172676574293B0A20';
wwv_flow_api.g_varchar2_table(465) := '202020202020202020202076617220636F6D6D656E74456C203D2065646974427574746F6E2E706172656E747328276C692E636F6D6D656E7427292E666972737428293B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20';
wwv_flow_api.g_varchar2_table(466) := '636F6D6D656E74456C2E6461746128292E6D6F64656C3B0A202020202020202020202020636F6D6D656E74456C2E616464436C61737328276564697427293B0A0A2020202020202020202020202F2F20437265617465207468652065646974696E672066';
wwv_flow_api.g_varchar2_table(467) := '69656C640A20202020202020202020202076617220656469744669656C64203D20746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E7428636F6D6D656E744D6F64656C2E706172656E742C20636F6D6D656E744D6F64656C';
wwv_flow_api.g_varchar2_table(468) := '2E6964293B0A202020202020202020202020636F6D6D656E74456C2E66696E6428272E636F6D6D656E742D7772617070657227292E666972737428292E617070656E6428656469744669656C64293B0A0A2020202020202020202020202F2F2041707065';
wwv_flow_api.g_varchar2_table(469) := '6E64206F726967696E616C20636F6E74656E740A202020202020202020202020766172207465787461726561203D20656469744669656C642E66696E6428272E746578746172656127293B0A20202020202020202020202074657874617265612E617474';
wwv_flow_api.g_varchar2_table(470) := '722827646174612D636F6D6D656E74272C20636F6D6D656E744D6F64656C2E6964293B0A0A2020202020202020202020202F2F204573636170696E672048544D4C0A20202020202020202020202074657874617265612E617070656E6428746869732E67';
wwv_flow_api.g_varchar2_table(471) := '6574466F726D6174746564436F6D6D656E74436F6E74656E7428636F6D6D656E744D6F64656C2C207472756529293B0A0A2020202020202020202020202F2F204D6F766520637572736F7220746F20656E640A202020202020202020202020746869732E';
wwv_flow_api.g_varchar2_table(472) := '6D6F7665437572736F72546F456E64287465787461726561293B0A0A2020202020202020202020202F2F20456E7375726520656C656D656E742073746179732076697369626C650A202020202020202020202020746869732E656E73757265456C656D65';
wwv_flow_api.g_varchar2_table(473) := '6E74537461797356697369626C6528656469744669656C64293B0A20202020202020207D2C0A0A202020202020202073686F7744726F707061626C654F7665726C61793A2066756E6374696F6E28657629207B0A20202020202020202020202069662874';
wwv_flow_api.g_varchar2_table(474) := '6869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A20202020202020202020202020202020746869732E24656C2E66696E6428272E64726F707061626C652D6F7665726C617927292E6373732827746F70272C2074686973';
wwv_flow_api.g_varchar2_table(475) := '2E24656C5B305D2E7363726F6C6C546F70293B0A20202020202020202020202020202020746869732E24656C2E66696E6428272E64726F707061626C652D6F7665726C617927292E73686F7728293B0A2020202020202020202020202020202074686973';
wwv_flow_api.g_varchar2_table(476) := '2E24656C2E616464436C6173732827647261672D6F6E676F696E6727293B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202068616E646C6544726167456E7465723A2066756E6374696F6E28657629207B0A202020';
wwv_flow_api.g_varchar2_table(477) := '20202020202020202076617220636F756E74203D20242865762E63757272656E74546172676574292E646174612827646E642D636F756E742729207C7C20303B0A202020202020202020202020636F756E742B2B3B0A2020202020202020202020202428';
wwv_flow_api.g_varchar2_table(478) := '65762E63757272656E74546172676574292E646174612827646E642D636F756E74272C20636F756E74293B0A202020202020202020202020242865762E63757272656E74546172676574292E616464436C6173732827647261672D6F76657227293B0A20';
wwv_flow_api.g_varchar2_table(479) := '202020202020207D2C0A0A202020202020202068616E646C65447261674C656176653A2066756E6374696F6E2865762C2063616C6C6261636B29207B0A20202020202020202020202076617220636F756E74203D20242865762E63757272656E74546172';
wwv_flow_api.g_varchar2_table(480) := '676574292E646174612827646E642D636F756E7427293B0A202020202020202020202020636F756E742D2D3B0A202020202020202020202020242865762E63757272656E74546172676574292E646174612827646E642D636F756E74272C20636F756E74';
wwv_flow_api.g_varchar2_table(481) := '293B0A0A202020202020202020202020696628636F756E74203D3D203029207B0A20202020202020202020202020202020242865762E63757272656E74546172676574292E72656D6F7665436C6173732827647261672D6F76657227293B0A2020202020';
wwv_flow_api.g_varchar2_table(482) := '202020202020202020202069662863616C6C6261636B292063616C6C6261636B28293B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202068616E646C65447261674C65617665466F724F7665726C61793A2066756E';
wwv_flow_api.g_varchar2_table(483) := '6374696F6E28657629207B0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020202020746869732E68616E646C65447261674C656176652865762C2066756E6374696F6E2829207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(484) := '2020202020202073656C662E6869646544726F707061626C654F7665726C617928293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A202020202020202068616E646C65447261674C65617665466F7244726F707061626C653A';
wwv_flow_api.g_varchar2_table(485) := '2066756E6374696F6E28657629207B0A202020202020202020202020746869732E68616E646C65447261674C65617665286576293B0A20202020202020207D2C0A0A202020202020202068616E646C65447261674F766572466F724F7665726C61793A20';
wwv_flow_api.g_varchar2_table(486) := '66756E6374696F6E28657629207B0A20202020202020202020202065762E73746F7050726F7061676174696F6E28293B0A20202020202020202020202065762E70726576656E7444656661756C7428293B0A20202020202020202020202065762E6F7269';
wwv_flow_api.g_varchar2_table(487) := '67696E616C4576656E742E646174615472616E736665722E64726F70456666656374203D2027636F7079273B0A20202020202020207D2C0A0A20202020202020206869646544726F707061626C654F7665726C61793A2066756E6374696F6E2829207B0A';
wwv_flow_api.g_varchar2_table(488) := '202020202020202020202020746869732E24656C2E66696E6428272E64726F707061626C652D6F7665726C617927292E6869646528293B0A202020202020202020202020746869732E24656C2E72656D6F7665436C6173732827647261672D6F6E676F69';
wwv_flow_api.g_varchar2_table(489) := '6E6727293B0A20202020202020207D2C0A0A202020202020202068616E646C6544726F703A2066756E6374696F6E28657629207B0A20202020202020202020202065762E70726576656E7444656661756C7428293B0A0A2020202020202020202020202F';
wwv_flow_api.g_varchar2_table(490) := '2F20526573657420444E4420636F756E74730A202020202020202020202020242865762E746172676574292E747269676765722827647261676C6561766527293B0A0A2020202020202020202020202F2F204869646520746865206F7665726C61792061';
wwv_flow_api.g_varchar2_table(491) := '6E642075706C6F6164207468652066696C65730A202020202020202020202020746869732E6869646544726F707061626C654F7665726C617928293B0A202020202020202020202020746869732E707265536176654174746163686D656E74732865762E';
wwv_flow_api.g_varchar2_table(492) := '6F726967696E616C4576656E742E646174615472616E736665722E66696C6573293B0A20202020202020207D2C0A0A202020202020202073746F7050726F7061676174696F6E3A2066756E6374696F6E28657629207B0A20202020202020202020202065';
wwv_flow_api.g_varchar2_table(493) := '762E73746F7050726F7061676174696F6E28293B0A20202020202020207D2C0A0A0A20202020202020202F2F2048544D4C20656C656D656E74730A20202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D0A0A202020202020202063726561746548';
wwv_flow_api.g_varchar2_table(494) := '544D4C3A2066756E6374696F6E2829207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A2020202020202020202020202F2F20436F6D6D656E74696E67206669656C640A202020202020202020202020766172206D61696E';
wwv_flow_api.g_varchar2_table(495) := '436F6D6D656E74696E674669656C64203D20746869732E6372656174654D61696E436F6D6D656E74696E674669656C64456C656D656E7428293B0A202020202020202020202020746869732E24656C2E617070656E64286D61696E436F6D6D656E74696E';
wwv_flow_api.g_varchar2_table(496) := '674669656C64293B0A0A2020202020202020202020202F2F204869646520636F6E74726F6C20726F7720616E6420636C6F736520627574746F6E0A202020202020202020202020766172206D61696E436F6E74726F6C526F77203D206D61696E436F6D6D';
wwv_flow_api.g_varchar2_table(497) := '656E74696E674669656C642E66696E6428272E636F6E74726F6C2D726F7727293B0A2020202020202020202020206D61696E436F6E74726F6C526F772E6869646528293B0A2020202020202020202020206D61696E436F6D6D656E74696E674669656C64';
wwv_flow_api.g_varchar2_table(498) := '2E66696E6428272E636C6F736527292E6869646528293B0A0A2020202020202020202020202F2F204E617669676174696F6E206261720A20202020202020202020202069662028746869732E6F7074696F6E732E656E61626C654E617669676174696F6E';
wwv_flow_api.g_varchar2_table(499) := '29207B0A20202020202020202020202020202020746869732E24656C2E617070656E6428746869732E6372656174654E617669676174696F6E456C656D656E742829293B0A20202020202020202020202020202020746869732E73686F77416374697665';
wwv_flow_api.g_varchar2_table(500) := '536F727428293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F204C6F6164696E67207370696E6E65720A202020202020202020202020766172207370696E6E6572203D20746869732E6372656174655370696E6E65722829';
wwv_flow_api.g_varchar2_table(501) := '3B0A202020202020202020202020746869732E24656C2E617070656E64287370696E6E6572293B0A0A2020202020202020202020202F2F20436F6D6D656E747320636F6E7461696E65720A20202020202020202020202076617220636F6D6D656E747343';
wwv_flow_api.g_varchar2_table(502) := '6F6E7461696E6572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A2027646174612D636F6E7461696E6572272C0A2020202020202020202020202020202027646174612D636F6E7461696E657227';
wwv_flow_api.g_varchar2_table(503) := '3A2027636F6D6D656E7473270A2020202020202020202020207D293B0A202020202020202020202020746869732E24656C2E617070656E6428636F6D6D656E7473436F6E7461696E6572293B0A0A2020202020202020202020202F2F20224E6F20636F6D';
wwv_flow_api.g_varchar2_table(504) := '6D656E74732220706C616365686F6C6465720A202020202020202020202020766172206E6F436F6D6D656E7473203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E6F2D636F6D6D656E747320';
wwv_flow_api.g_varchar2_table(505) := '6E6F2D64617461272C0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E6F436F6D6D656E747354657874290A202020202020202020202020';
wwv_flow_api.g_varchar2_table(506) := '7D293B0A202020202020202020202020766172206E6F436F6D6D656E747349636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D636F6D6D656E74732066612D3278270A202020';
wwv_flow_api.g_varchar2_table(507) := '2020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E6E6F436F6D6D656E747349636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020206E6F436F6D6D656E747349636F6E2E';
wwv_flow_api.g_varchar2_table(508) := '63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E6E6F436F6D6D656E747349636F6E55524C2B27222927293B0A202020202020202020202020202020206E6F436F6D6D656E747349636F6E';
wwv_flow_api.g_varchar2_table(509) := '2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A2020202020202020202020206E6F436F6D6D656E74732E70726570656E64282428273C62722F3E2729292E70726570656E64286E6F436F6D6D656E747349636F6E29';
wwv_flow_api.g_varchar2_table(510) := '3B0A202020202020202020202020636F6D6D656E7473436F6E7461696E65722E617070656E64286E6F436F6D6D656E7473293B0A0A2020202020202020202020202F2F204174746163686D656E74730A202020202020202020202020696628746869732E';
wwv_flow_api.g_varchar2_table(511) := '6F7074696F6E732E656E61626C654174746163686D656E747329207B0A0A202020202020202020202020202020202F2F204174746163686D656E747320636F6E7461696E65720A20202020202020202020202020202020766172206174746163686D656E';
wwv_flow_api.g_varchar2_table(512) := '7473436F6E7461696E6572203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A2027646174612D636F6E7461696E6572272C0A20202020202020202020202020202020202020202764617461';
wwv_flow_api.g_varchar2_table(513) := '2D636F6E7461696E6572273A20276174746163686D656E7473270A202020202020202020202020202020207D293B0A20202020202020202020202020202020746869732E24656C2E617070656E64286174746163686D656E7473436F6E7461696E657229';
wwv_flow_api.g_varchar2_table(514) := '3B0A0A202020202020202020202020202020202F2F20224E6F206174746163686D656E74732220706C616365686F6C6465720A20202020202020202020202020202020766172206E6F4174746163686D656E7473203D202428273C6469762F3E272C207B';
wwv_flow_api.g_varchar2_table(515) := '0A202020202020202020202020202020202020202027636C617373273A20276E6F2D6174746163686D656E7473206E6F2D64617461272C0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E7465787446';
wwv_flow_api.g_varchar2_table(516) := '6F726D617474657228746869732E6F7074696F6E732E6E6F4174746163686D656E747354657874290A202020202020202020202020202020207D293B0A20202020202020202020202020202020766172206E6F4174746163686D656E747349636F6E203D';
wwv_flow_api.g_varchar2_table(517) := '202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202766612066612D7061706572636C69702066612D3278270A202020202020202020202020202020207D293B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(518) := '2020696628746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E67746829207B0A20202020202020202020202020202020202020206E6F4174746163686D656E747349636F6E2E63737328276261636B67726F756E642D';
wwv_flow_api.g_varchar2_table(519) := '696D616765272C202775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927293B0A20202020202020202020202020202020202020206E6F4174746163686D656E747349636F6E2E616464436C617373';
wwv_flow_api.g_varchar2_table(520) := '2827696D61676527293B0A202020202020202020202020202020207D0A202020202020202020202020202020206E6F4174746163686D656E74732E70726570656E64282428273C62722F3E2729292E70726570656E64286E6F4174746163686D656E7473';
wwv_flow_api.g_varchar2_table(521) := '49636F6E293B0A202020202020202020202020202020206174746163686D656E7473436F6E7461696E65722E617070656E64286E6F4174746163686D656E7473293B0A0A0A202020202020202020202020202020202F2F204472616720262064726F7070';
wwv_flow_api.g_varchar2_table(522) := '696E67206174746163686D656E74730A202020202020202020202020202020207661722064726F707061626C654F7665726C6179203D202428273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202764';
wwv_flow_api.g_varchar2_table(523) := '726F707061626C652D6F7665726C6179270A202020202020202020202020202020207D293B0A0A202020202020202020202020202020207661722064726F707061626C65436F6E7461696E6572203D202428273C6469762F3E272C207B0A202020202020';
wwv_flow_api.g_varchar2_table(524) := '202020202020202020202020202027636C617373273A202764726F707061626C652D636F6E7461696E6572270A202020202020202020202020202020207D293B0A0A202020202020202020202020202020207661722064726F707061626C65203D202428';
wwv_flow_api.g_varchar2_table(525) := '273C6469762F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202764726F707061626C65270A202020202020202020202020202020207D293B0A0A202020202020202020202020202020207661722075706C6F6164';
wwv_flow_api.g_varchar2_table(526) := '49636F6E203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202766612066612D7061706572636C69702066612D3478270A202020202020202020202020202020207D293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(527) := '2020202020202020696628746869732E6F7074696F6E732E75706C6F616449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020202020202075706C6F616449636F6E2E63737328276261636B67726F756E642D696D616765';
wwv_flow_api.g_varchar2_table(528) := '272C202775726C2822272B746869732E6F7074696F6E732E75706C6F616449636F6E55524C2B27222927293B0A202020202020202020202020202020202020202075706C6F616449636F6E2E616464436C6173732827696D61676527293B0A2020202020';
wwv_flow_api.g_varchar2_table(529) := '20202020202020202020207D0A0A202020202020202020202020202020207661722064726F704174746163686D656E7454657874203D202428273C6469762F3E272C207B0A2020202020202020202020202020202020202020746578743A20746869732E';
wwv_flow_api.g_varchar2_table(530) := '6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6174746163686D656E7444726F7054657874290A202020202020202020202020202020207D293B0A2020202020202020202020202020202064726F707061626C65';
wwv_flow_api.g_varchar2_table(531) := '2E617070656E642875706C6F616449636F6E293B0A2020202020202020202020202020202064726F707061626C652E617070656E642864726F704174746163686D656E7454657874293B0A0A2020202020202020202020202020202064726F707061626C';
wwv_flow_api.g_varchar2_table(532) := '654F7665726C61792E68746D6C2864726F707061626C65436F6E7461696E65722E68746D6C2864726F707061626C6529292E6869646528293B0A20202020202020202020202020202020746869732E24656C2E617070656E642864726F707061626C654F';
wwv_flow_api.g_varchar2_table(533) := '7665726C6179293B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202063726561746550726F66696C6550696374757265456C656D656E743A2066756E6374696F6E287372632C2075736572496429207B0A20202020';
wwv_flow_api.g_varchar2_table(534) := '202020202020202069662873726329207B0A20202020202020202020202020207661722070726F66696C6550696374757265203D202428273C6469762F3E27292E637373287B0A202020202020202020202020202020202020276261636B67726F756E64';
wwv_flow_api.g_varchar2_table(535) := '2D696D616765273A202775726C2827202B20737263202B202729270A202020202020202020202020202020207D293B0A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020207661722070726F66696C6550696374';
wwv_flow_api.g_varchar2_table(536) := '757265203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202766612066612D75736572270A202020202020202020202020202020207D293B0A2020202020202020202020207D0A202020202020';
wwv_flow_api.g_varchar2_table(537) := '20202020202070726F66696C65506963747572652E616464436C617373282770726F66696C652D7069637475726527293B0A20202020202020202020202070726F66696C65506963747572652E617474722827646174612D757365722D6964272C207573';
wwv_flow_api.g_varchar2_table(538) := '65724964293B0A202020202020202020202020696628746869732E6F7074696F6E732E726F756E6450726F66696C655069637475726573292070726F66696C65506963747572652E616464436C6173732827726F756E6427293B0A202020202020202020';
wwv_flow_api.g_varchar2_table(539) := '20202072657475726E2070726F66696C65506963747572653B0A20202020202020207D2C0A0A20202020202020206372656174654D61696E436F6D6D656E74696E674669656C64456C656D656E743A2066756E6374696F6E2829207B0A20202020202020';
wwv_flow_api.g_varchar2_table(540) := '202020202072657475726E20746869732E637265617465436F6D6D656E74696E674669656C64456C656D656E7428756E646566696E65642C20756E646566696E65642C2074727565293B0A20202020202020207D2C0A0A20202020202020206372656174';
wwv_flow_api.g_varchar2_table(541) := '65436F6D6D656E74696E674669656C64456C656D656E743A2066756E6374696F6E28706172656E7449642C206578697374696E67436F6D6D656E7449642C2069734D61696E29207B0A2020202020202020202020207661722073656C66203D2074686973';
wwv_flow_api.g_varchar2_table(542) := '3B0A0A2020202020202020202020207661722070726F66696C655069637475726555524C3B0A202020202020202020202020766172207573657249643B0A202020202020202020202020766172206174746163686D656E74733B0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(543) := '202020202F2F20436F6D6D656E74696E67206669656C640A20202020202020202020202076617220636F6D6D656E74696E674669656C64203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A2027636F';
wwv_flow_api.g_varchar2_table(544) := '6D6D656E74696E672D6669656C64270A2020202020202020202020207D293B0A20202020202020202020202069662869734D61696E2920636F6D6D656E74696E674669656C642E616464436C61737328276D61696E27293B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(545) := '20202F2F20436F6D6D656E7420776173206D6F6469666965642C20757365206578697374696E6720646174610A2020202020202020202020206966286578697374696E67436F6D6D656E74496429207B0A2020202020202020202020202020202070726F';
wwv_flow_api.g_varchar2_table(546) := '66696C655069637475726555524C203D20746869732E636F6D6D656E7473427949645B6578697374696E67436F6D6D656E7449645D2E70726F66696C655069637475726555524C3B0A20202020202020202020202020202020757365724964203D207468';
wwv_flow_api.g_varchar2_table(547) := '69732E636F6D6D656E7473427949645B6578697374696E67436F6D6D656E7449645D2E63726561746F723B0A202020202020202020202020202020206174746163686D656E7473203D20746869732E636F6D6D656E7473427949645B6578697374696E67';
wwv_flow_api.g_varchar2_table(548) := '436F6D6D656E7449645D2E6174746163686D656E74733B0A0A2020202020202020202020202F2F204E657720636F6D6D656E742077617320637265617465640A2020202020202020202020207D20656C7365207B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(549) := '2070726F66696C655069637475726555524C203D20746869732E6F7074696F6E732E70726F66696C655069637475726555524C3B0A20202020202020202020202020202020757365724964203D20746869732E6F7074696F6E732E63726561746F723B0A';
wwv_flow_api.g_varchar2_table(550) := '202020202020202020202020202020206174746163686D656E7473203D205B5D3B0A2020202020202020202020207D0A0A2020202020202020202020207661722070726F66696C6550696374757265203D20746869732E63726561746550726F66696C65';
wwv_flow_api.g_varchar2_table(551) := '50696374757265456C656D656E742870726F66696C655069637475726555524C2C20757365724964293B0A0A2020202020202020202020202F2F204E657720636F6D6D656E740A2020202020202020202020207661722074657874617265615772617070';
wwv_flow_api.g_varchar2_table(552) := '6572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A202774657874617265612D77726170706572270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20436F6E7472';
wwv_flow_api.g_varchar2_table(553) := '6F6C20726F770A20202020202020202020202076617220636F6E74726F6C526F77203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A2027636F6E74726F6C2D726F77270A2020202020202020202020';
wwv_flow_api.g_varchar2_table(554) := '207D293B0A0A2020202020202020202020202F2F2054657874617265610A202020202020202020202020766172207465787461726561203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A2027746578';
wwv_flow_api.g_varchar2_table(555) := '7461726561272C0A2020202020202020202020202020202027646174612D706C616365686F6C646572273A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E7465787461726561506C616365686F6C';
wwv_flow_api.g_varchar2_table(556) := '64657254657874292C0A20202020202020202020202020202020636F6E74656E746564697461626C653A20747275650A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2053657474696E672074686520696E697469616C20';
wwv_flow_api.g_varchar2_table(557) := '68656967687420666F72207468652074657874617265610A202020202020202020202020746869732E61646A75737454657874617265614865696768742874657874617265612C2066616C7365293B0A0A2020202020202020202020202F2F20436C6F73';
wwv_flow_api.g_varchar2_table(558) := '6520627574746F6E0A20202020202020202020202076617220636C6F7365427574746F6E203D20746869732E637265617465436C6F7365427574746F6E28293B0A202020202020202020202020636C6F7365427574746F6E2E616464436C617373282769';
wwv_flow_api.g_varchar2_table(559) := '6E6C696E652D627574746F6E27293B0A0A2020202020202020202020202F2F205361766520627574746F6E0A2020202020202020202020207661722073617665427574746F6E436C617373203D206578697374696E67436F6D6D656E744964203F202775';
wwv_flow_api.g_varchar2_table(560) := '706461746527203A202773656E64273B0A2020202020202020202020207661722073617665427574746F6E54657874203D206578697374696E67436F6D6D656E744964203F20746869732E6F7074696F6E732E74657874466F726D617474657228746869';
wwv_flow_api.g_varchar2_table(561) := '732E6F7074696F6E732E736176655465787429203A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E73656E6454657874293B0A2020202020202020202020207661722073617665427574746F6E20';
wwv_flow_api.g_varchar2_table(562) := '3D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A2073617665427574746F6E436C617373202B2027207361766520686967686C696768742D6261636B67726F756E64272C0A20202020202020202020';
wwv_flow_api.g_varchar2_table(563) := '2020202020202774657874273A2073617665427574746F6E546578740A2020202020202020202020207D293B0A20202020202020202020202073617665427574746F6E2E6461746128276F726967696E616C2D636F6E74656E74272C2073617665427574';
wwv_flow_api.g_varchar2_table(564) := '746F6E54657874293B0A202020202020202020202020636F6E74726F6C526F772E617070656E642873617665427574746F6E293B0A0A2020202020202020202020202F2F2044656C65746520627574746F6E0A2020202020202020202020206966286578';
wwv_flow_api.g_varchar2_table(565) := '697374696E67436F6D6D656E74496420262620746869732E6973416C6C6F776564546F44656C657465286578697374696E67436F6D6D656E7449642929207B0A0A202020202020202020202020202020202F2F2044656C65746520627574746F6E0A2020';
wwv_flow_api.g_varchar2_table(566) := '20202020202020202020202020207661722064656C657465427574746F6E54657874203D20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E64656C65746554657874293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(567) := '2020202020207661722064656C657465427574746F6E203D202428273C7370616E2F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202764656C65746520656E61626C6564272C0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(568) := '20202020202020746578743A2064656C657465427574746F6E546578740A202020202020202020202020202020207D292E63737328276261636B67726F756E642D636F6C6F72272C20746869732E6F7074696F6E732E64656C657465427574746F6E436F';
wwv_flow_api.g_varchar2_table(569) := '6C6F72293B0A2020202020202020202020202020202064656C657465427574746F6E2E6461746128276F726967696E616C2D636F6E74656E74272C2064656C657465427574746F6E54657874293B0A20202020202020202020202020202020636F6E7472';
wwv_flow_api.g_varchar2_table(570) := '6F6C526F772E617070656E642864656C657465427574746F6E293B0A2020202020202020202020207D0A0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A0A20202020202020';
wwv_flow_api.g_varchar2_table(571) := '2020202020202020202F2F2055706C6F616420627574746F6E730A202020202020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A202020202020202020202020202020207661722075706C6F6164427574746F6E203D20242827';
wwv_flow_api.g_varchar2_table(572) := '3C7370616E2F3E272C207B0A202020202020202020202020202020202020202027636C617373273A2027656E61626C65642075706C6F6164270A202020202020202020202020202020207D293B0A20202020202020202020202020202020766172207570';
wwv_flow_api.g_varchar2_table(573) := '6C6F616449636F6E203D202428273C692F3E272C207B0A202020202020202020202020202020202020202027636C617373273A202766612066612D7061706572636C6970270A202020202020202020202020202020207D293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(574) := '2020202020207661722066696C65496E707574203D202428273C696E7075742F3E272C207B0A20202020202020202020202020202020202020202774797065273A202766696C65272C0A2020202020202020202020202020202020202020276D756C7469';
wwv_flow_api.g_varchar2_table(575) := '706C65273A20276D756C7469706C65272C0A202020202020202020202020202020202020202027646174612D726F6C65273A20276E6F6E6527202F2F2050726576656E74206A71756572792D6D6F62696C6520666F7220616464696E6720636C61737365';
wwv_flow_api.g_varchar2_table(576) := '730A202020202020202020202020202020207D293B0A0A20202020202020202020202020202020696628746869732E6F7074696F6E732E75706C6F616449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020202020202075';
wwv_flow_api.g_varchar2_table(577) := '706C6F616449636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E75706C6F616449636F6E55524C2B27222927293B0A202020202020202020202020202020202020202075706C6F';
wwv_flow_api.g_varchar2_table(578) := '616449636F6E2E616464436C6173732827696D61676527293B0A202020202020202020202020202020207D0A2020202020202020202020202020202075706C6F6164427574746F6E2E617070656E642875706C6F616449636F6E292E617070656E642866';
wwv_flow_api.g_varchar2_table(579) := '696C65496E707574293B0A0A202020202020202020202020202020202F2F204D61696E2075706C6F616420627574746F6E0A20202020202020202020202020202020766172206D61696E55706C6F6164427574746F6E203D2075706C6F6164427574746F';
wwv_flow_api.g_varchar2_table(580) := '6E2E636C6F6E6528293B0A202020202020202020202020202020206D61696E55706C6F6164427574746F6E2E6461746128276F726967696E616C2D636F6E74656E74272C206D61696E55706C6F6164427574746F6E2E6368696C6472656E2829293B0A20';
wwv_flow_api.g_varchar2_table(581) := '202020202020202020202020202020636F6E74726F6C526F772E617070656E64286D61696E55706C6F6164427574746F6E293B0A0A202020202020202020202020202020202F2F20496E6C696E652075706C6F616420627574746F6E20666F72206D6169';
wwv_flow_api.g_varchar2_table(582) := '6E20636F6D6D656E74696E67206669656C640A2020202020202020202020202020202069662869734D61696E29207B0A20202020202020202020202020202020202020207465787461726561577261707065722E617070656E642875706C6F6164427574';
wwv_flow_api.g_varchar2_table(583) := '746F6E2E636C6F6E6528292E616464436C6173732827696E6C696E652D627574746F6E2729293B0A202020202020202020202020202020207D0A0A202020202020202020202020202020202F2F204174746163686D656E747320636F6E7461696E65720A';
wwv_flow_api.g_varchar2_table(584) := '202020202020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D0A0A20202020202020202020202020202020766172206174746163686D656E7473436F6E7461696E6572203D202428273C6469762F3E272C207B0A20';
wwv_flow_api.g_varchar2_table(585) := '2020202020202020202020202020202020202027636C617373273A20276174746163686D656E7473272C0A202020202020202020202020202020207D293B0A2020202020202020202020202020202024286174746163686D656E7473292E656163682866';
wwv_flow_api.g_varchar2_table(586) := '756E6374696F6E28696E6465782C206174746163686D656E7429207B0A2020202020202020202020202020202020202020766172206174746163686D656E74546167203D2073656C662E6372656174654174746163686D656E74546167456C656D656E74';
wwv_flow_api.g_varchar2_table(587) := '286174746163686D656E742C2074727565293B0A20202020202020202020202020202020202020206174746163686D656E7473436F6E7461696E65722E617070656E64286174746163686D656E74546167293B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(588) := '7D293B0A20202020202020202020202020202020636F6E74726F6C526F772E617070656E64286174746163686D656E7473436F6E7461696E6572293B0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F20506F70756C617465';
wwv_flow_api.g_varchar2_table(589) := '2074686520656C656D656E740A2020202020202020202020207465787461726561577261707065722E617070656E6428636C6F7365427574746F6E292E617070656E64287465787461726561292E617070656E6428636F6E74726F6C526F77293B0A2020';
wwv_flow_api.g_varchar2_table(590) := '20202020202020202020636F6D6D656E74696E674669656C642E617070656E642870726F66696C6550696374757265292E617070656E6428746578746172656157726170706572293B0A0A0A202020202020202020202020696628706172656E74496429';
wwv_flow_api.g_varchar2_table(591) := '207B0A0A202020202020202020202020202020202F2F205365742074686520706172656E7420696420746F20746865206669656C64206966206E65636573736172790A2020202020202020202020202020202074657874617265612E6174747228276461';
wwv_flow_api.g_varchar2_table(592) := '74612D706172656E74272C20706172656E744964293B0A0A202020202020202020202020202020202F2F20417070656E64207265706C792D746F20746167206966206E65636573736172790A202020202020202020202020202020207661722070617265';
wwv_flow_api.g_varchar2_table(593) := '6E744D6F64656C203D20746869732E636F6D6D656E7473427949645B706172656E7449645D3B0A20202020202020202020202020202020696628706172656E744D6F64656C2E706172656E7429207B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(594) := '74657874617265612E68746D6C2827266E6273703B27293B202020202F2F204E656564656420746F207365742074686520637572736F7220746F20636F727265637420706C6163650A0A20202020202020202020202020202020202020202F2F20437265';
wwv_flow_api.g_varchar2_table(595) := '6174696E6720746865207265706C792D746F207461670A2020202020202020202020202020202020202020766172207265706C79546F4E616D65203D20274027202B20706172656E744D6F64656C2E66756C6C6E616D653B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(596) := '202020202020202020766172207265706C79546F546167203D20746869732E637265617465546167456C656D656E74287265706C79546F4E616D652C20277265706C792D746F272C20706172656E744D6F64656C2E63726561746F722C207B0A20202020';
wwv_flow_api.g_varchar2_table(597) := '202020202020202020202020202020202020202027646174612D757365722D6964273A20706172656E744D6F64656C2E63726561746F720A20202020202020202020202020202020202020207D293B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(598) := '74657874617265612E70726570656E64287265706C79546F546167293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F2050696E67696E672075736572730A2020202020202020';
wwv_flow_api.g_varchar2_table(599) := '20202020696628746869732E6F7074696F6E732E656E61626C6550696E67696E6729207B0A2020202020202020202020202020202074657874617265612E74657874636F6D706C657465285B7B0A20202020202020202020202020202020202020206D61';
wwv_flow_api.g_varchar2_table(600) := '7463683A202F285E7C5C732940285B5E405D2A29242F692C0A2020202020202020202020202020202020202020696E6465783A20322C0A20202020202020202020202020202020202020207365617263683A2066756E6374696F6E20287465726D2C2063';
wwv_flow_api.g_varchar2_table(601) := '616C6C6261636B29207B0A2020202020202020202020202020202020202020202020207465726D203D2073656C662E6E6F726D616C697A65537061636573287465726D293B0A0A2020202020202020202020202020202020202020202020202F2F205265';
wwv_flow_api.g_varchar2_table(602) := '7475726E20656D707479206172726179206F6E206572726F720A202020202020202020202020202020202020202020202020766172206572726F72203D2066756E6374696F6E2829207B0A20202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(603) := '20202063616C6C6261636B285B5D293B0A2020202020202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202020202073656C662E6F7074696F6E732E7365617263685573657273287465726D2C2063';
wwv_flow_api.g_varchar2_table(604) := '616C6C6261636B2C206572726F72293B0A20202020202020202020202020202020202020207D2C0A202020202020202020202020202020202020202074656D706C6174653A2066756E6374696F6E287573657229207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(605) := '20202020202020202020207661722077726170706572203D202428273C6469762F3E27293B0A0A2020202020202020202020202020202020202020202020207661722070726F66696C6550696374757265456C203D2073656C662E63726561746550726F';
wwv_flow_api.g_varchar2_table(606) := '66696C6550696374757265456C656D656E7428757365722E70726F66696C655F706963747572655F75726C293B0A0A2020202020202020202020202020202020202020202020207661722064657461696C73456C203D202428273C6469762F3E272C207B';
wwv_flow_api.g_varchar2_table(607) := '0A2020202020202020202020202020202020202020202020202020202027636C617373273A202764657461696C73272C0A2020202020202020202020202020202020202020202020207D293B0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(608) := '20766172206E616D65456C203D202428273C6469762F3E272C207B0A2020202020202020202020202020202020202020202020202020202027636C617373273A20276E616D65272C0A2020202020202020202020202020202020202020202020207D292E';
wwv_flow_api.g_varchar2_table(609) := '68746D6C28757365722E66756C6C6E616D65293B0A0A20202020202020202020202020202020202020202020202076617220656D61696C456C203D202428273C6469762F3E272C207B0A2020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(610) := '202027636C617373273A2027656D61696C272C0A2020202020202020202020202020202020202020202020207D292E68746D6C28757365722E656D61696C293B0A0A20202020202020202020202020202020202020202020202069662028757365722E65';
wwv_flow_api.g_varchar2_table(611) := '6D61696C29207B0A2020202020202020202020202020202020202020202020202020202064657461696C73456C2E617070656E64286E616D65456C292E617070656E6428656D61696C456C293B0A20202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(612) := '20207D20656C7365207B0A2020202020202020202020202020202020202020202020202020202064657461696C73456C2E616464436C61737328276E6F2D656D61696C27290A202020202020202020202020202020202020202020202020202020206465';
wwv_flow_api.g_varchar2_table(613) := '7461696C73456C2E617070656E64286E616D65456C290A2020202020202020202020202020202020202020202020207D0A0A202020202020202020202020202020202020202020202020777261707065722E617070656E642870726F66696C6550696374';
wwv_flow_api.g_varchar2_table(614) := '757265456C292E617070656E642864657461696C73456C293B0A20202020202020202020202020202020202020202020202072657475726E20777261707065722E68746D6C28293B0A20202020202020202020202020202020202020207D2C0A20202020';
wwv_flow_api.g_varchar2_table(615) := '202020202020202020202020202020207265706C6163653A2066756E6374696F6E20287573657229207B0A20202020202020202020202020202020202020202020202076617220746167203D2073656C662E637265617465546167456C656D656E742827';
wwv_flow_api.g_varchar2_table(616) := '4027202B20757365722E66756C6C6E616D652C202770696E67272C20757365722E69642C207B0A2020202020202020202020202020202020202020202020202020202027646174612D757365722D6964273A20757365722E69640A202020202020202020';
wwv_flow_api.g_varchar2_table(617) := '2020202020202020202020202020207D293B0A20202020202020202020202020202020202020202020202072657475726E20272027202B207461675B305D2E6F7574657248544D4C202B202720273B0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(618) := '7D2C0A202020202020202020202020202020207D5D2C207B0A2020202020202020202020202020202020202020617070656E64546F3A20272E6A71756572792D636F6D6D656E7473272C0A202020202020202020202020202020202020202064726F7064';
wwv_flow_api.g_varchar2_table(619) := '6F776E436C6173734E616D653A202764726F70646F776E206175746F636F6D706C657465272C0A20202020202020202020202020202020202020206D6178436F756E743A20352C0A20202020202020202020202020202020202020207269676874456467';
wwv_flow_api.g_varchar2_table(620) := '654F66667365743A20302C0A20202020202020202020202020202020202020206465626F756E63653A203235300A202020202020202020202020202020207D293B0A0A0A202020202020202020202020202020202F2F204F564552494445205445585443';
wwv_flow_api.g_varchar2_table(621) := '4F4D504C4554452044524F50444F574E20504F534954494F4E494E470A0A20202020202020202020202020202020242E666E2E74657874636F6D706C6574652E44726F70646F776E2E70726F746F747970652E72656E646572203D2066756E6374696F6E';
wwv_flow_api.g_varchar2_table(622) := '287A69707065644461746129207B0A202020202020202020202020202020202020202076617220636F6E74656E747348746D6C203D20746869732E5F6275696C64436F6E74656E7473287A697070656444617461293B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(623) := '2020202020202076617220756E7A697070656444617461203D20242E6D6170287A6970706564446174612C2066756E6374696F6E20286429207B2072657475726E20642E76616C75653B207D293B0A202020202020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(624) := '6620287A6970706564446174612E6C656E67746829207B0A20202020202020202020202020202020202020202020766172207374726174656779203D207A6970706564446174615B305D2E73747261746567793B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(625) := '202020202020206966202873747261746567792E696429207B0A202020202020202020202020202020202020202020202020746869732E24656C2E617474722827646174612D7374726174656779272C2073747261746567792E6964293B0A2020202020';
wwv_flow_api.g_varchar2_table(626) := '20202020202020202020202020202020207D20656C7365207B0A202020202020202020202020202020202020202020202020746869732E24656C2E72656D6F7665417474722827646174612D737472617465677927293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(627) := '202020202020202020207D0A20202020202020202020202020202020202020202020746869732E5F72656E64657248656164657228756E7A697070656444617461293B0A20202020202020202020202020202020202020202020746869732E5F72656E64';
wwv_flow_api.g_varchar2_table(628) := '6572466F6F74657228756E7A697070656444617461293B0A2020202020202020202020202020202020202020202069662028636F6E74656E747348746D6C29207B0A202020202020202020202020202020202020202020202020746869732E5F72656E64';
wwv_flow_api.g_varchar2_table(629) := '6572436F6E74656E747328636F6E74656E747348746D6C293B0A202020202020202020202020202020202020202020202020746869732E5F666974546F426F74746F6D28293B0A202020202020202020202020202020202020202020202020746869732E';
wwv_flow_api.g_varchar2_table(630) := '5F666974546F526967687428293B0A202020202020202020202020202020202020202020202020746869732E5F6163746976617465496E64657865644974656D28293B0A202020202020202020202020202020202020202020207D0A2020202020202020';
wwv_flow_api.g_varchar2_table(631) := '2020202020202020202020202020746869732E5F7365745363726F6C6C28293B0A20202020202020202020202020202020202020207D20656C73652069662028746869732E6E6F526573756C74734D65737361676529207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(632) := '2020202020202020202020746869732E5F72656E6465724E6F526573756C74734D65737361676528756E7A697070656444617461293B0A20202020202020202020202020202020202020207D20656C73652069662028746869732E73686F776E29207B0A';
wwv_flow_api.g_varchar2_table(633) := '20202020202020202020202020202020202020202020746869732E6465616374697661746528293B0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202F2F20435553544F4D20434F44450A20';
wwv_flow_api.g_varchar2_table(634) := '202020202020202020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D0A0A20202020202020202020202020202020202020202F2F2041646A75737420766572746963616C20706F736974696F6E0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(635) := '20202076617220746F70203D207061727365496E7428746869732E24656C2E6373732827746F70272929202B2073656C662E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F7028293B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(636) := '20202020202020746869732E24656C2E6373732827746F70272C20746F70293B0A0A20202020202020202020202020202020202020202F2F2041646A75737420686F72697A6F6E74616C20706F736974696F6E0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(637) := '20202020766172206F726967696E616C4C656674203D20746869732E24656C2E63737328276C65667427293B0A2020202020202020202020202020202020202020746869732E24656C2E63737328276C656674272C2030293B202020202F2F204C656674';
wwv_flow_api.g_varchar2_table(638) := '206D7573742062652073657420746F203020696E206F7264657220746F2067657420746865207265616C207769647468206F662074686520656C0A2020202020202020202020202020202020202020766172206D61784C656674203D2073656C662E2465';
wwv_flow_api.g_varchar2_table(639) := '6C2E77696474682829202D20746869732E24656C2E6F75746572576964746828293B0A2020202020202020202020202020202020202020766172206C656674203D204D6174682E6D696E286D61784C6566742C207061727365496E74286F726967696E61';
wwv_flow_api.g_varchar2_table(640) := '6C4C65667429293B0A2020202020202020202020202020202020202020746869732E24656C2E63737328276C656674272C206C656674293B0A0A20202020202020202020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D0A20202020202020';
wwv_flow_api.g_varchar2_table(641) := '2020202020202020207D0A0A0A202020202020202020202020202020202F2F204F5645524944452054455854434F4D504C45544520434F4E54454E544544495441424C4520534B49505345415243482046554E4354494F4E205748454E205553494E4720';
wwv_flow_api.g_varchar2_table(642) := '414C54202B206261636B73706163650A0A20202020202020202020202020202020242E666E2E74657874636F6D706C6574652E436F6E74656E744564697461626C652E70726F746F747970652E5F736B6970536561726368203D2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(643) := '636C69636B4576656E7429207B0A20202020202020202020202020202020202020207377697463682028636C69636B4576656E742E6B6579436F646529207B0A2020202020202020202020202020202020202020202020206361736520393A20202F2F20';
wwv_flow_api.g_varchar2_table(644) := '5441420A202020202020202020202020202020202020202020202020636173652031333A202F2F20454E5445520A202020202020202020202020202020202020202020202020636173652031363A202F2F2053484946540A202020202020202020202020';
wwv_flow_api.g_varchar2_table(645) := '202020202020202020202020636173652031373A202F2F204354524C0A2020202020202020202020202020202020202020202020202F2F636173652031383A202F2F20414C540A2020202020202020202020202020202020202020202020206361736520';
wwv_flow_api.g_varchar2_table(646) := '33333A202F2F205041474555500A202020202020202020202020202020202020202020202020636173652033343A202F2F2050414745444F574E0A202020202020202020202020202020202020202020202020636173652034303A202F2F20444F574E0A';
wwv_flow_api.g_varchar2_table(647) := '202020202020202020202020202020202020202020202020636173652033383A202F2F2055500A202020202020202020202020202020202020202020202020636173652032373A202F2F204553430A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(648) := '2020202020202072657475726E20747275653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020202020202069662028636C69636B4576656E742E6374726C4B657929207377697463682028636C69636B45';
wwv_flow_api.g_varchar2_table(649) := '76656E742E6B6579436F646529207B0A202020202020202020202020202020202020202020202020636173652037383A202F2F204374726C2D4E0A202020202020202020202020202020202020202020202020636173652038303A202F2F204374726C2D';
wwv_flow_api.g_varchar2_table(650) := '500A2020202020202020202020202020202020202020202020202020202072657475726E20747275653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020';
wwv_flow_api.g_varchar2_table(651) := '2020202020202020202072657475726E20636F6D6D656E74696E674669656C643B0A20202020202020207D2C0A0A20202020202020206372656174654E617669676174696F6E456C656D656E743A2066756E6374696F6E2829207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(652) := '20202020766172206E617669676174696F6E456C203D202428273C756C2F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E617669676174696F6E270A2020202020202020202020207D293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(653) := '2020766172206E617669676174696F6E57726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E617669676174696F6E2D77726170706572270A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(654) := '3B0A2020202020202020202020206E617669676174696F6E456C2E617070656E64286E617669676174696F6E57726170706572293B0A0A2020202020202020202020202F2F204E65776573740A202020202020202020202020766172206E657765737420';
wwv_flow_api.g_varchar2_table(655) := '3D202428273C6C692F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6E657765737454657874292C0A20202020202020202020';
wwv_flow_api.g_varchar2_table(656) := '20202020202027646174612D736F72742D6B6579273A20276E6577657374272C0A2020202020202020202020202020202027646174612D636F6E7461696E65722D6E616D65273A2027636F6D6D656E7473270A2020202020202020202020207D293B0A0A';
wwv_flow_api.g_varchar2_table(657) := '2020202020202020202020202F2F204F6C646573740A202020202020202020202020766172206F6C64657374203D202428273C6C692F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E7465787446';
wwv_flow_api.g_varchar2_table(658) := '6F726D617474657228746869732E6F7074696F6E732E6F6C6465737454657874292C0A2020202020202020202020202020202027646174612D736F72742D6B6579273A20276F6C64657374272C0A2020202020202020202020202020202027646174612D';
wwv_flow_api.g_varchar2_table(659) := '636F6E7461696E65722D6E616D65273A2027636F6D6D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20506F70756C61720A20202020202020202020202076617220706F70756C6172203D202428273C6C69';
wwv_flow_api.g_varchar2_table(660) := '2F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E706F70756C617254657874292C0A2020202020202020202020202020202027';
wwv_flow_api.g_varchar2_table(661) := '646174612D736F72742D6B6579273A2027706F70756C6172697479272C0A2020202020202020202020202020202027646174612D636F6E7461696E65722D6E616D65273A2027636F6D6D656E7473270A2020202020202020202020207D293B0A0A202020';
wwv_flow_api.g_varchar2_table(662) := '2020202020202020202F2F204174746163686D656E74730A202020202020202020202020766172206174746163686D656E7473203D202428273C6C692F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F7074696F6E';
wwv_flow_api.g_varchar2_table(663) := '732E74657874466F726D617474657228746869732E6F7074696F6E732E6174746163686D656E747354657874292C0A2020202020202020202020202020202027646174612D736F72742D6B6579273A20276174746163686D656E7473272C0A2020202020';
wwv_flow_api.g_varchar2_table(664) := '202020202020202020202027646174612D636F6E7461696E65722D6E616D65273A20276174746163686D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204174746163686D656E74732069636F6E0A202020';
wwv_flow_api.g_varchar2_table(665) := '202020202020202020766172206174746163686D656E747349636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7061706572636C6970270A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(666) := '3B0A202020202020202020202020696628746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020206174746163686D656E747349636F6E2E63737328276261636B67';
wwv_flow_api.g_varchar2_table(667) := '726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927293B0A202020202020202020202020202020206174746163686D656E747349636F6E2E616464436C617373';
wwv_flow_api.g_varchar2_table(668) := '2827696D61676527293B0A2020202020202020202020207D0A2020202020202020202020206174746163686D656E74732E70726570656E64286174746163686D656E747349636F6E293B0A0A0A2020202020202020202020202F2F20526573706F6E7369';
wwv_flow_api.g_varchar2_table(669) := '7665206E617669676174696F6E0A2020202020202020202020207661722064726F70646F776E4E617669676174696F6E57726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E61';
wwv_flow_api.g_varchar2_table(670) := '7669676174696F6E2D7772617070657220726573706F6E73697665270A2020202020202020202020207D293B0A2020202020202020202020207661722064726F70646F776E4E617669676174696F6E203D202428273C756C2F3E272C207B0A2020202020';
wwv_flow_api.g_varchar2_table(671) := '202020202020202020202027636C617373273A202764726F70646F776E270A2020202020202020202020207D293B0A2020202020202020202020207661722064726F70646F776E5469746C65203D202428273C6C692F3E272C207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(672) := '202020202020202027636C617373273A20277469746C65270A2020202020202020202020207D293B0A2020202020202020202020207661722064726F70646F776E5469746C65486561646572203D202428273C6865616465722F3E27293B0A0A20202020';
wwv_flow_api.g_varchar2_table(673) := '202020202020202064726F70646F776E5469746C652E617070656E642864726F70646F776E5469746C65486561646572293B0A20202020202020202020202064726F70646F776E4E617669676174696F6E577261707065722E617070656E642864726F70';
wwv_flow_api.g_varchar2_table(674) := '646F776E5469746C65293B0A20202020202020202020202064726F70646F776E4E617669676174696F6E577261707065722E617070656E642864726F70646F776E4E617669676174696F6E293B0A2020202020202020202020206E617669676174696F6E';
wwv_flow_api.g_varchar2_table(675) := '456C2E617070656E642864726F70646F776E4E617669676174696F6E57726170706572293B0A0A0A2020202020202020202020202F2F20506F70756C61746520656C656D656E74730A2020202020202020202020206E617669676174696F6E5772617070';
wwv_flow_api.g_varchar2_table(676) := '65722E617070656E64286E6577657374292E617070656E64286F6C64657374293B0A20202020202020202020202064726F70646F776E4E617669676174696F6E2E617070656E64286E65776573742E636C6F6E652829292E617070656E64286F6C646573';
wwv_flow_api.g_varchar2_table(677) := '742E636C6F6E652829293B0A0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C655265706C79696E67207C7C20746869732E6F7074696F6E732E656E61626C655570766F74696E6729207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(678) := '2020202020206E617669676174696F6E577261707065722E617070656E6428706F70756C6172293B0A2020202020202020202020202020202064726F70646F776E4E617669676174696F6E2E617070656E6428706F70756C61722E636C6F6E652829293B';
wwv_flow_api.g_varchar2_table(679) := '0A2020202020202020202020207D0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C654174746163686D656E747329207B0A202020202020202020202020202020206E617669676174696F6E577261707065722E6170';
wwv_flow_api.g_varchar2_table(680) := '70656E64286174746163686D656E7473293B0A2020202020202020202020202020202064726F70646F776E4E617669676174696F6E577261707065722E617070656E64286174746163686D656E74732E636C6F6E652829293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(681) := '20207D0A0A202020202020202020202020696628746869732E6F7074696F6E732E666F726365526573706F6E736976652920746869732E666F726365526573706F6E7369766528293B0A20202020202020202020202072657475726E206E617669676174';
wwv_flow_api.g_varchar2_table(682) := '696F6E456C3B0A20202020202020207D2C0A0A20202020202020206372656174655370696E6E65723A2066756E6374696F6E28696E6C696E6529207B0A202020202020202020202020766172207370696E6E6572203D202428273C6469762F3E272C207B';
wwv_flow_api.g_varchar2_table(683) := '0A2020202020202020202020202020202027636C617373273A20277370696E6E6572270A2020202020202020202020207D293B0A202020202020202020202020696628696E6C696E6529207370696E6E65722E616464436C6173732827696E6C696E6527';
wwv_flow_api.g_varchar2_table(684) := '293B0A0A202020202020202020202020766172207370696E6E657249636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7370696E6E65722066612D7370696E270A2020202020';
wwv_flow_api.g_varchar2_table(685) := '202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E7370696E6E657249636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020207370696E6E657249636F6E2E6373732827626163';
wwv_flow_api.g_varchar2_table(686) := '6B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E7370696E6E657249636F6E55524C2B27222927293B0A202020202020202020202020202020207370696E6E657249636F6E2E616464436C6173732827696D61';
wwv_flow_api.g_varchar2_table(687) := '676527293B0A2020202020202020202020207D0A2020202020202020202020207370696E6E65722E68746D6C287370696E6E657249636F6E293B0A20202020202020202020202072657475726E207370696E6E65723B0A20202020202020207D2C0A0A20';
wwv_flow_api.g_varchar2_table(688) := '20202020202020637265617465436C6F7365427574746F6E3A2066756E6374696F6E28636C6173734E616D6529207B0A20202020202020202020202076617220636C6F7365427574746F6E203D202428273C7370616E2F3E272C207B0A20202020202020';
wwv_flow_api.g_varchar2_table(689) := '20202020202020202027636C617373273A20636C6173734E616D65207C7C2027636C6F7365270A2020202020202020202020207D293B0A0A2020202020202020202020207661722069636F6E203D202428273C692F3E272C207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(690) := '2020202020202027636C617373273A202766612066612D74696D6573270A2020202020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E636C6F736549636F6E55524C2E6C656E67746829207B0A202020';
wwv_flow_api.g_varchar2_table(691) := '2020202020202020202020202069636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E636C6F736549636F6E55524C2B27222927293B0A2020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(692) := '636F6E2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A0A202020202020202020202020636C6F7365427574746F6E2E68746D6C2869636F6E293B0A0A20202020202020202020202072657475726E20636C6F736542';
wwv_flow_api.g_varchar2_table(693) := '7574746F6E3B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E74456C656D656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C29207B0A0A2020202020202020202020202F2F20436F6D6D656E7420636F';
wwv_flow_api.g_varchar2_table(694) := '6E7461696E657220656C656D656E740A20202020202020202020202076617220636F6D6D656E74456C203D202428273C6C692F3E272C207B0A2020202020202020202020202020202027646174612D6964273A20636F6D6D656E744D6F64656C2E69642C';
wwv_flow_api.g_varchar2_table(695) := '0A2020202020202020202020202020202027636C617373273A2027636F6D6D656E74270A2020202020202020202020207D292E6461746128276D6F64656C272C20636F6D6D656E744D6F64656C293B0A0A202020202020202020202020696628636F6D6D';
wwv_flow_api.g_varchar2_table(696) := '656E744D6F64656C2E63726561746564427943757272656E74557365722920636F6D6D656E74456C2E616464436C617373282762792D63757272656E742D7573657227293B0A202020202020202020202020696628636F6D6D656E744D6F64656C2E6372';
wwv_flow_api.g_varchar2_table(697) := '6561746564427941646D696E2920636F6D6D656E74456C2E616464436C617373282762792D61646D696E27293B0A0A2020202020202020202020202F2F204368696C6420636F6D6D656E74730A202020202020202020202020766172206368696C64436F';
wwv_flow_api.g_varchar2_table(698) := '6D6D656E7473203D202428273C756C2F3E272C207B0A2020202020202020202020202020202027636C617373273A20276368696C642D636F6D6D656E7473270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20436F6D6D';
wwv_flow_api.g_varchar2_table(699) := '656E7420777261707065720A20202020202020202020202076617220636F6D6D656E7457726170706572203D20746869732E637265617465436F6D6D656E7457726170706572456C656D656E7428636F6D6D656E744D6F64656C293B0A0A202020202020';
wwv_flow_api.g_varchar2_table(700) := '202020202020636F6D6D656E74456C2E617070656E6428636F6D6D656E7457726170706572293B0A202020202020202020202020696628636F6D6D656E744D6F64656C2E706172656E74203D3D206E756C6C2920636F6D6D656E74456C2E617070656E64';
wwv_flow_api.g_varchar2_table(701) := '286368696C64436F6D6D656E7473293B0A20202020202020202020202072657475726E20636F6D6D656E74456C3B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E7457726170706572456C656D656E743A2066756E63';
wwv_flow_api.g_varchar2_table(702) := '74696F6E28636F6D6D656E744D6F64656C29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202076617220636F6D6D656E7457726170706572203D202428273C6469762F3E272C207B0A2020';
wwv_flow_api.g_varchar2_table(703) := '202020202020202020202020202027636C617373273A2027636F6D6D656E742D77726170706572270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F2050726F66696C6520706963747572650A2020202020202020202020';
wwv_flow_api.g_varchar2_table(704) := '207661722070726F66696C6550696374757265203D20746869732E63726561746550726F66696C6550696374757265456C656D656E7428636F6D6D656E744D6F64656C2E70726F66696C655069637475726555524C2C20636F6D6D656E744D6F64656C2E';
wwv_flow_api.g_varchar2_table(705) := '63726561746F72293B0A0A2020202020202020202020202F2F2054696D650A2020202020202020202020207661722074696D65203D202428273C74696D652F3E272C207B0A20202020202020202020202020202020746578743A20746869732E6F707469';
wwv_flow_api.g_varchar2_table(706) := '6F6E732E74696D65466F726D617474657228636F6D6D656E744D6F64656C2E63726561746564292C0A2020202020202020202020202020202027646174612D6F726967696E616C273A20636F6D6D656E744D6F64656C2E637265617465640A2020202020';
wwv_flow_api.g_varchar2_table(707) := '202020202020207D293B0A0A2020202020202020202020202F2F20436F6D6D656E742068656164657220656C656D656E740A20202020202020202020202076617220636F6D6D656E74486561646572456C203D202428273C6469762F3E272C207B0A2020';
wwv_flow_api.g_varchar2_table(708) := '202020202020202020202020202027636C617373273A2027636F6D6D656E742D686561646572272C0A2020202020202020202020207D293B0A0A2020202020202020202020202F2F204E616D6520656C656D656E740A2020202020202020202020207661';
wwv_flow_api.g_varchar2_table(709) := '72206E616D65456C203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A20276E616D65272C0A2020202020202020202020202020202027646174612D757365722D6964273A20636F6D6D656E744D6F';
wwv_flow_api.g_varchar2_table(710) := '64656C2E63726561746F722C0A202020202020202020202020202020202774657874273A20636F6D6D656E744D6F64656C2E63726561746564427943757272656E7455736572203F20746869732E6F7074696F6E732E74657874466F726D617474657228';
wwv_flow_api.g_varchar2_table(711) := '746869732E6F7074696F6E732E796F755465787429203A20636F6D6D656E744D6F64656C2E66756C6C6E616D650A2020202020202020202020207D293B0A202020202020202020202020636F6D6D656E74486561646572456C2E617070656E64286E616D';
wwv_flow_api.g_varchar2_table(712) := '65456C293B0A0A0A2020202020202020202020202F2F20486967686C696768742061646D696E206E616D65730A202020202020202020202020696628636F6D6D656E744D6F64656C2E63726561746564427941646D696E29206E616D65456C2E61646443';
wwv_flow_api.g_varchar2_table(713) := '6C6173732827686967686C696768742D666F6E742D626F6C6427293B0A0A2020202020202020202020202F2F2053686F77207265706C792D746F206E616D6520696620706172656E74206F6620706172656E74206578697374730A202020202020202020';
wwv_flow_api.g_varchar2_table(714) := '202020696628636F6D6D656E744D6F64656C2E706172656E7429207B0A2020202020202020202020202020202076617220706172656E74203D20746869732E636F6D6D656E7473427949645B636F6D6D656E744D6F64656C2E706172656E745D3B0A2020';
wwv_flow_api.g_varchar2_table(715) := '2020202020202020202020202020696628706172656E742E706172656E7429207B0A2020202020202020202020202020202020202020766172207265706C79546F203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(716) := '2020202020202027636C617373273A20277265706C792D746F272C0A2020202020202020202020202020202020202020202020202774657874273A20706172656E742E66756C6C6E616D652C0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(717) := '2027646174612D757365722D6964273A20706172656E742E63726561746F720A20202020202020202020202020202020202020207D293B0A0A20202020202020202020202020202020202020202F2F207265706C792069636F6E0A202020202020202020';
wwv_flow_api.g_varchar2_table(718) := '2020202020202020202020766172207265706C7949636F6E203D202428273C692F3E272C207B0A20202020202020202020202020202020202020202020202027636C617373273A202766612066612D7368617265270A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(719) := '2020202020207D293B0A2020202020202020202020202020202020202020696628746869732E6F7074696F6E732E7265706C7949636F6E55524C2E6C656E67746829207B0A2020202020202020202020202020202020202020202020207265706C794963';
wwv_flow_api.g_varchar2_table(720) := '6F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E7265706C7949636F6E55524C2B27222927293B0A2020202020202020202020202020202020202020202020207265706C7949636F';
wwv_flow_api.g_varchar2_table(721) := '6E2E616464436C6173732827696D61676527293B0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020207265706C79546F2E70726570656E64287265706C7949636F6E293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(722) := '202020202020202020202020636F6D6D656E74486561646572456C2E617070656E64287265706C79546F293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A0A2020202020202020202020202F2F204E657720746167';
wwv_flow_api.g_varchar2_table(723) := '0A202020202020202020202020696628636F6D6D656E744D6F64656C2E69734E657729207B0A20202020202020202020202020202020766172206E6577546167203D202428273C7370616E2F3E272C207B0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(724) := '202027636C617373273A20276E657720686967686C696768742D6261636B67726F756E64272C0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074';
wwv_flow_api.g_varchar2_table(725) := '696F6E732E6E657754657874290A202020202020202020202020202020207D293B0A20202020202020202020202020202020636F6D6D656E74486561646572456C2E617070656E64286E6577546167293B0A2020202020202020202020207D0A0A202020';
wwv_flow_api.g_varchar2_table(726) := '2020202020202020202F2F20577261707065720A2020202020202020202020207661722077726170706572203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A202777726170706572270A2020202020';
wwv_flow_api.g_varchar2_table(727) := '202020202020207D293B0A0A2020202020202020202020202F2F20436F6E74656E740A2020202020202020202020202F2F203D3D3D3D3D3D3D0A0A20202020202020202020202076617220636F6E74656E74203D202428273C6469762F3E272C207B0A20';
wwv_flow_api.g_varchar2_table(728) := '20202020202020202020202020202027636C617373273A2027636F6E74656E74270A2020202020202020202020207D293B0A202020202020202020202020636F6E74656E742E68746D6C28746869732E676574466F726D6174746564436F6D6D656E7443';
wwv_flow_api.g_varchar2_table(729) := '6F6E74656E7428636F6D6D656E744D6F64656C29293B0A0A2020202020202020202020202F2F204564697465642074696D657374616D700A202020202020202020202020696628636F6D6D656E744D6F64656C2E6D6F64696669656420262620636F6D6D';
wwv_flow_api.g_varchar2_table(730) := '656E744D6F64656C2E6D6F64696669656420213D20636F6D6D656E744D6F64656C2E6372656174656429207B0A202020202020202020202020202020207661722065646974656454696D65203D20746869732E6F7074696F6E732E74696D65466F726D61';
wwv_flow_api.g_varchar2_table(731) := '7474657228636F6D6D656E744D6F64656C2E6D6F646966696564293B0A2020202020202020202020202020202076617220656469746564203D202428273C74696D652F3E272C207B0A202020202020202020202020202020202020202027636C61737327';
wwv_flow_api.g_varchar2_table(732) := '3A2027656469746564272C0A2020202020202020202020202020202020202020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6564697465645465787429202B20272027202B206564';
wwv_flow_api.g_varchar2_table(733) := '6974656454696D652C0A202020202020202020202020202020202020202027646174612D6F726967696E616C273A20636F6D6D656E744D6F64656C2E6D6F6469666965640A202020202020202020202020202020207D293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(734) := '2020202020636F6E74656E742E617070656E6428656469746564293B0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F204174746163686D656E74730A2020202020202020202020202F2F203D3D3D3D3D3D3D3D3D3D3D0A0A';
wwv_flow_api.g_varchar2_table(735) := '202020202020202020202020766172206174746163686D656E7473203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20276174746163686D656E7473270A2020202020202020202020207D293B0A20';
wwv_flow_api.g_varchar2_table(736) := '2020202020202020202020766172206174746163686D656E745072657669657773203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A20277072657669657773270A2020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(737) := '3B0A202020202020202020202020766172206174746163686D656E7454616773203D202428273C6469762F3E272C207B0A2020202020202020202020202020202027636C617373273A202774616773270A2020202020202020202020207D293B0A202020';
wwv_flow_api.g_varchar2_table(738) := '2020202020202020206174746163686D656E74732E617070656E64286174746163686D656E745072657669657773292E617070656E64286174746163686D656E7454616773293B0A0A202020202020202020202020696628746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(739) := '2E656E61626C654174746163686D656E747320262620636F6D6D656E744D6F64656C2E6861734174746163686D656E7473282929207B0A202020202020202020202020202020202428636F6D6D656E744D6F64656C2E6174746163686D656E7473292E65';
wwv_flow_api.g_varchar2_table(740) := '6163682866756E6374696F6E28696E6465782C206174746163686D656E7429207B0A202020202020202020202020202020202020202076617220666F726D6174203D20756E646566696E65643B0A20202020202020202020202020202020202020207661';
wwv_flow_api.g_varchar2_table(741) := '722074797065203D20756E646566696E65643B0A0A20202020202020202020202020202020202020202F2F205479706520616E6420666F726D61740A20202020202020202020202020202020202020206966286174746163686D656E742E6D696D655F74';
wwv_flow_api.g_varchar2_table(742) := '79706529207B0A202020202020202020202020202020202020202020202020766172206D696D65547970655061727473203D206174746163686D656E742E6D696D655F747970652E73706C697428272F27293B0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(743) := '20202020202020206966286D696D655479706550617274732E6C656E677468203D3D203229207B0A20202020202020202020202020202020202020202020202020202020666F726D6174203D206D696D655479706550617274735B315D3B0A2020202020';
wwv_flow_api.g_varchar2_table(744) := '202020202020202020202020202020202020202020202074797065203D206D696D655479706550617274735B305D3B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D0A0A202020';
wwv_flow_api.g_varchar2_table(745) := '20202020202020202020202020202020202F2F20507265766965770A202020202020202020202020202020202020202069662874797065203D3D2027696D61676527207C7C2074797065203D3D2027766964656F2729207B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(746) := '202020202020202020202020207661722070726576696577526F77203D202428273C6469762F3E27293B0A0A2020202020202020202020202020202020202020202020202F2F205072657669657720656C656D656E740A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(747) := '20202020202020202020207661722070726576696577203D202428273C612F3E272C207B0A2020202020202020202020202020202020202020202020202020202027636C617373273A202770726576696577272C0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(748) := '20202020202020202020202020687265663A206174746163686D656E742E66696C652C0A202020202020202020202020202020202020202020202020202020207461726765743A20275F626C616E6B270A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(749) := '20202020207D293B0A20202020202020202020202020202020202020202020202070726576696577526F772E68746D6C2870726576696577293B0A0A2020202020202020202020202020202020202020202020202F2F20436173653A20696D6167652070';
wwv_flow_api.g_varchar2_table(750) := '7265766965770A20202020202020202020202020202020202020202020202069662874797065203D3D2027696D6167652729207B0A2020202020202020202020202020202020202020202020202020202076617220696D616765203D202428273C696D67';
wwv_flow_api.g_varchar2_table(751) := '2F3E272C207B0A20202020202020202020202020202020202020202020202020202020202020207372633A206174746163686D656E742E66696C650A202020202020202020202020202020202020202020202020202020207D293B0A2020202020202020';
wwv_flow_api.g_varchar2_table(752) := '2020202020202020202020202020202020202020707265766965772E68746D6C28696D616765293B0A0A2020202020202020202020202020202020202020202020202F2F20436173653A20766964656F20707265766965770A2020202020202020202020';
wwv_flow_api.g_varchar2_table(753) := '202020202020202020202020207D20656C7365207B0A2020202020202020202020202020202020202020202020202020202076617220766964656F203D202428273C766964656F2F3E272C207B0A20202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(754) := '202020202020202020207372633A206174746163686D656E742E66696C652C0A2020202020202020202020202020202020202020202020202020202020202020747970653A206174746163686D656E742E6D696D655F747970652C0A2020202020202020';
wwv_flow_api.g_varchar2_table(755) := '202020202020202020202020202020202020202020202020636F6E74726F6C733A2027636F6E74726F6C73270A202020202020202020202020202020202020202020202020202020207D293B0A2020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(756) := '2020202020707265766965772E68746D6C28766964656F293B0A2020202020202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020202020206174746163686D656E7450726576696577732E617070656E';
wwv_flow_api.g_varchar2_table(757) := '642870726576696577526F77293B0A20202020202020202020202020202020202020207D0A0A20202020202020202020202020202020202020202F2F2054616720656C656D656E740A202020202020202020202020202020202020202076617220617474';
wwv_flow_api.g_varchar2_table(758) := '6163686D656E74546167203D2073656C662E6372656174654174746163686D656E74546167456C656D656E74286174746163686D656E742C2066616C7365293B0A20202020202020202020202020202020202020206174746163686D656E74546167732E';
wwv_flow_api.g_varchar2_table(759) := '617070656E64286174746163686D656E74546167293B0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A0A0A2020202020202020202020202F2F20416374696F6E730A2020202020202020202020202F2F203D3D3D';
wwv_flow_api.g_varchar2_table(760) := '3D3D3D3D0A0A20202020202020202020202076617220616374696F6E73203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A2027616374696F6E73270A2020202020202020202020207D293B0A0A20';
wwv_flow_api.g_varchar2_table(761) := '20202020202020202020202F2F20536570617261746F720A20202020202020202020202076617220736570617261746F72203D202428273C7370616E2F3E272C207B0A2020202020202020202020202020202027636C617373273A202773657061726174';
wwv_flow_api.g_varchar2_table(762) := '6F72272C0A20202020202020202020202020202020746578743A2027C2B7270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F205265706C790A202020202020202020202020766172207265706C79203D202428273C6275';
wwv_flow_api.g_varchar2_table(763) := '74746F6E2F3E272C207B0A2020202020202020202020202020202027636C617373273A2027616374696F6E207265706C79272C0A202020202020202020202020202020202774797065273A2027627574746F6E272C0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(764) := '2020746578743A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E7265706C7954657874290A2020202020202020202020207D293B0A0A2020202020202020202020202F2F205570766F7465206963';
wwv_flow_api.g_varchar2_table(765) := '6F6E0A202020202020202020202020766172207570766F746549636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7468756D62732D7570270A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(766) := '293B0A202020202020202020202020696628746869732E6F7074696F6E732E7570766F746549636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020207570766F746549636F6E2E63737328276261636B67726F756E642D696D';
wwv_flow_api.g_varchar2_table(767) := '616765272C202775726C2822272B746869732E6F7074696F6E732E7570766F746549636F6E55524C2B27222927293B0A202020202020202020202020202020207570766F746549636F6E2E616464436C6173732827696D61676527293B0A202020202020';
wwv_flow_api.g_varchar2_table(768) := '2020202020207D0A0A2020202020202020202020202F2F205570766F7465730A202020202020202020202020766172207570766F746573203D20746869732E6372656174655570766F7465456C656D656E7428636F6D6D656E744D6F64656C293B0A0A20';
wwv_flow_api.g_varchar2_table(769) := '20202020202020202020202F2F20417070656E6420627574746F6E7320666F7220616374696F6E7320746861742061726520656E61626C65640A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C655265706C79696E67';
wwv_flow_api.g_varchar2_table(770) := '2920616374696F6E732E617070656E64287265706C79293B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C655570766F74696E672920616374696F6E732E617070656E64287570766F746573293B0A0A2020202020';
wwv_flow_api.g_varchar2_table(771) := '20202020202020696628636F6D6D656E744D6F64656C2E63726561746564427943757272656E7455736572207C7C20746869732E6F7074696F6E732E63757272656E7455736572497341646D696E29207B0A202020202020202020202020202020207661';
wwv_flow_api.g_varchar2_table(772) := '722065646974427574746F6E203D202428273C627574746F6E2F3E272C207B0A202020202020202020202020202020202020202027636C617373273A2027616374696F6E2065646974272C0A202020202020202020202020202020202020202074657874';
wwv_flow_api.g_varchar2_table(773) := '3A20746869732E6F7074696F6E732E74657874466F726D617474657228746869732E6F7074696F6E732E6564697454657874290A202020202020202020202020202020207D293B0A20202020202020202020202020202020616374696F6E732E61707065';
wwv_flow_api.g_varchar2_table(774) := '6E642865646974427574746F6E293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20417070656E6420736570617261746F7273206265747765656E2074686520616374696F6E730A20202020202020202020202061637469';
wwv_flow_api.g_varchar2_table(775) := '6F6E732E6368696C6472656E28292E656163682866756E6374696F6E28696E6465782C20616374696F6E456C29207B0A20202020202020202020202020202020696628212428616374696F6E456C292E697328273A6C6173742D6368696C64272929207B';
wwv_flow_api.g_varchar2_table(776) := '0A20202020202020202020202020202020202020202428616374696F6E456C292E616674657228736570617261746F722E636C6F6E652829293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A0A202020202020';
wwv_flow_api.g_varchar2_table(777) := '202020202020777261707065722E617070656E6428636F6E74656E74293B0A202020202020202020202020777261707065722E617070656E64286174746163686D656E7473293B0A202020202020202020202020777261707065722E617070656E642861';
wwv_flow_api.g_varchar2_table(778) := '6374696F6E73293B0A202020202020202020202020636F6D6D656E74577261707065722E617070656E642870726F66696C6550696374757265292E617070656E642874696D65292E617070656E6428636F6D6D656E74486561646572456C292E61707065';
wwv_flow_api.g_varchar2_table(779) := '6E642877726170706572293B0A20202020202020202020202072657475726E20636F6D6D656E74577261707065723B0A20202020202020207D2C0A0A20202020202020206372656174655570766F7465456C656D656E743A2066756E6374696F6E28636F';
wwv_flow_api.g_varchar2_table(780) := '6D6D656E744D6F64656C29207B0A2020202020202020202020202F2F205570766F74652069636F6E0A202020202020202020202020766172207570766F746549636F6E203D202428273C692F3E272C207B0A202020202020202020202020202020202763';
wwv_flow_api.g_varchar2_table(781) := '6C617373273A202766612066612D7468756D62732D7570270A2020202020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E7570766F746549636F6E55524C2E6C656E67746829207B0A20202020202020';
wwv_flow_api.g_varchar2_table(782) := '2020202020202020207570766F746549636F6E2E63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E7570766F746549636F6E55524C2B27222927293B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(783) := '20207570766F746549636F6E2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F205570766F7465730A202020202020202020202020766172207570766F7465456C203D20242827';
wwv_flow_api.g_varchar2_table(784) := '3C627574746F6E2F3E272C207B0A2020202020202020202020202020202027636C617373273A2027616374696F6E207570766F746527202B2028636F6D6D656E744D6F64656C2E757365724861735570766F746564203F202720686967686C696768742D';
wwv_flow_api.g_varchar2_table(785) := '666F6E7427203A202727290A2020202020202020202020207D292E617070656E64282428273C7370616E2F3E272C207B0A20202020202020202020202020202020746578743A20636F6D6D656E744D6F64656C2E7570766F7465436F756E742C0A202020';
wwv_flow_api.g_varchar2_table(786) := '2020202020202020202020202027636C617373273A20277570766F74652D636F756E74270A2020202020202020202020207D29292E617070656E64287570766F746549636F6E293B0A0A20202020202020202020202072657475726E207570766F746545';
wwv_flow_api.g_varchar2_table(787) := '6C3B0A20202020202020207D2C0A0A2020202020202020637265617465546167456C656D656E743A2066756E6374696F6E28746578742C206578747261436C61737365732C2076616C75652C2065787472614174747269627574657329207B0A20202020';
wwv_flow_api.g_varchar2_table(788) := '202020202020202076617220746167456C203D202428273C696E7075742F3E272C207B0A2020202020202020202020202020202027636C617373273A2027746167272C0A202020202020202020202020202020202774797065273A2027627574746F6E27';
wwv_flow_api.g_varchar2_table(789) := '2C0A2020202020202020202020202020202027646174612D726F6C65273A20276E6F6E65272C0A2020202020202020202020207D293B0A2020202020202020202020206966286578747261436C61737365732920746167456C2E616464436C6173732865';
wwv_flow_api.g_varchar2_table(790) := '78747261436C6173736573293B0A202020202020202020202020746167456C2E76616C2874657874293B0A202020202020202020202020746167456C2E617474722827646174612D76616C7565272C2076616C7565293B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(791) := '696620286578747261417474726962757465732920746167456C2E6174747228657874726141747472696275746573293B0A20202020202020202020202072657475726E20746167456C3B0A20202020202020207D2C0A0A202020202020202063726561';
wwv_flow_api.g_varchar2_table(792) := '74654174746163686D656E74546167456C656D656E743A2066756E6374696F6E286174746163686D656E742C2064656C657461626C6529207B0A2020202020202020202020200A2020202020202020202020202F2F2054616720656C656D656E740A2020';
wwv_flow_api.g_varchar2_table(793) := '20202020202020202020766172206174746163686D656E74546167203D202428273C612F3E272C207B0A2020202020202020202020202020202027636C617373273A2027746167206174746163686D656E74272C0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(794) := '2027746172676574273A20275F626C616E6B270A2020202020202020202020207D293B0A0A2020202020202020202020202F2F20536574206872656620617474726962757465206966206E6F742064656C657461626C650A202020202020202020202020';
wwv_flow_api.g_varchar2_table(795) := '6966282164656C657461626C6529207B0A202020202020202020202020202020206174746163686D656E745461672E61747472282768726566272C206174746163686D656E742E66696C65293B0A2020202020202020202020207D0A0A20202020202020';
wwv_flow_api.g_varchar2_table(796) := '20202020202F2F2042696E6420646174610A2020202020202020202020206174746163686D656E745461672E64617461287B0A2020202020202020202020202020202069643A206174746163686D656E742E69642C0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(797) := '20206D696D655F747970653A206174746163686D656E742E6D696D655F747970652C0A2020202020202020202020202020202066696C653A206174746163686D656E742E66696C652C0A2020202020202020202020207D293B0A0A202020202020202020';
wwv_flow_api.g_varchar2_table(798) := '2020202F2F2046696C65206E616D650A2020202020202020202020207661722066696C654E616D65203D2027273B0A0A2020202020202020202020202F2F20436173653A2066696C652069732066696C65206F626A6563740A2020202020202020202020';
wwv_flow_api.g_varchar2_table(799) := '206966286174746163686D656E742E66696C6520696E7374616E63656F662046696C6529207B0A2020202020202020202020202020202066696C654E616D65203D206174746163686D656E742E66696C652E6E616D653B0A0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(800) := '202F2F20436173653A2066696C652069732055524C0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020766172207061727473203D206174746163686D656E742E66696C652E73706C697428272F27293B0A20';
wwv_flow_api.g_varchar2_table(801) := '2020202020202020202020202020207661722066696C654E616D65203D2070617274735B70617274732E6C656E677468202D20315D3B0A2020202020202020202020202020202066696C654E616D65203D2066696C654E616D652E73706C697428273F27';
wwv_flow_api.g_varchar2_table(802) := '295B305D3B0A2020202020202020202020202020202066696C654E616D65203D206465636F6465555249436F6D706F6E656E742866696C654E616D65293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F204174746163686D';
wwv_flow_api.g_varchar2_table(803) := '656E742069636F6E0A202020202020202020202020766172206174746163686D656E7449636F6E203D202428273C692F3E272C207B0A2020202020202020202020202020202027636C617373273A202766612066612D7061706572636C6970270A202020';
wwv_flow_api.g_varchar2_table(804) := '2020202020202020207D293B0A202020202020202020202020696628746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2E6C656E67746829207B0A202020202020202020202020202020206174746163686D656E7449636F6E2E';
wwv_flow_api.g_varchar2_table(805) := '63737328276261636B67726F756E642D696D616765272C202775726C2822272B746869732E6F7074696F6E732E6174746163686D656E7449636F6E55524C2B27222927293B0A202020202020202020202020202020206174746163686D656E7449636F6E';
wwv_flow_api.g_varchar2_table(806) := '2E616464436C6173732827696D61676527293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20417070656E6420636F6E74656E740A2020202020202020202020206174746163686D656E745461672E617070656E64286174';
wwv_flow_api.g_varchar2_table(807) := '746163686D656E7449636F6E2C2066696C654E616D65293B0A0A2020202020202020202020202F2F204164642064656C65746520627574746F6E2069662064656C657461626C650A20202020202020202020202069662864656C657461626C6529207B0A';
wwv_flow_api.g_varchar2_table(808) := '202020202020202020202020202020206174746163686D656E745461672E616464436C617373282764656C657461626C6527293B0A0A202020202020202020202020202020202F2F20417070656E6420636C6F736520627574746F6E0A20202020202020';
wwv_flow_api.g_varchar2_table(809) := '20202020202020202076617220636C6F7365427574746F6E203D20746869732E637265617465436C6F7365427574746F6E282764656C65746527293B0A202020202020202020202020202020206174746163686D656E745461672E617070656E6428636C';
wwv_flow_api.g_varchar2_table(810) := '6F7365427574746F6E293B0A2020202020202020202020207D0A0A20202020202020202020202072657475726E206174746163686D656E745461673B0A20202020202020207D2C0A0A2020202020202020726552656E646572436F6D6D656E743A206675';
wwv_flow_api.g_varchar2_table(811) := '6E6374696F6E28696429207B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B69645D3B0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D';
wwv_flow_api.g_varchar2_table(812) := '20746869732E24656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E69642B27225D27293B0A0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020';
wwv_flow_api.g_varchar2_table(813) := '202020636F6D6D656E74456C656D656E74732E656163682866756E6374696F6E28696E6465782C20636F6D6D656E74456C29207B0A2020202020202020202020202020202076617220636F6D6D656E7457726170706572203D2073656C662E6372656174';
wwv_flow_api.g_varchar2_table(814) := '65436F6D6D656E7457726170706572456C656D656E7428636F6D6D656E744D6F64656C293B0A202020202020202020202020202020202428636F6D6D656E74456C292E66696E6428272E636F6D6D656E742D7772617070657227292E666972737428292E';
wwv_flow_api.g_varchar2_table(815) := '7265706C6163655769746828636F6D6D656E7457726170706572293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A2020202020202020726552656E646572436F6D6D656E74416374696F6E4261723A2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(816) := '696429207B0A20202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B69645D3B0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24';
wwv_flow_api.g_varchar2_table(817) := '656C2E66696E6428276C692E636F6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E69642B27225D27293B0A0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020202020636F6D6D';
wwv_flow_api.g_varchar2_table(818) := '656E74456C656D656E74732E656163682866756E6374696F6E28696E6465782C20636F6D6D656E74456C29207B0A2020202020202020202020202020202076617220636F6D6D656E7457726170706572203D2073656C662E637265617465436F6D6D656E';
wwv_flow_api.g_varchar2_table(819) := '7457726170706572456C656D656E7428636F6D6D656E744D6F64656C293B0A202020202020202020202020202020202428636F6D6D656E74456C292E66696E6428272E616374696F6E7327292E666972737428292E7265706C6163655769746828636F6D';
wwv_flow_api.g_varchar2_table(820) := '6D656E74577261707065722E66696E6428272E616374696F6E732729293B0A2020202020202020202020207D293B0A20202020202020207D2C0A0A2020202020202020726552656E6465725570766F7465733A2066756E6374696F6E28696429207B0A20';
wwv_flow_api.g_varchar2_table(821) := '202020202020202020202076617220636F6D6D656E744D6F64656C203D20746869732E636F6D6D656E7473427949645B69645D3B0A20202020202020202020202076617220636F6D6D656E74456C656D656E7473203D20746869732E24656C2E66696E64';
wwv_flow_api.g_varchar2_table(822) := '28276C692E636F6D6D656E745B646174612D69643D22272B636F6D6D656E744D6F64656C2E69642B27225D27293B0A0A2020202020202020202020207661722073656C66203D20746869733B0A202020202020202020202020636F6D6D656E74456C656D';
wwv_flow_api.g_varchar2_table(823) := '656E74732E656163682866756E6374696F6E28696E6465782C20636F6D6D656E74456C29207B0A20202020202020202020202020202020766172207570766F746573203D2073656C662E6372656174655570766F7465456C656D656E7428636F6D6D656E';
wwv_flow_api.g_varchar2_table(824) := '744D6F64656C293B0A202020202020202020202020202020202428636F6D6D656E74456C292E66696E6428272E7570766F746527292E666972737428292E7265706C61636557697468287570766F746573293B0A2020202020202020202020207D293B0A';
wwv_flow_api.g_varchar2_table(825) := '20202020202020207D2C0A0A0A20202020202020202F2F205374796C696E670A20202020202020202F2F203D3D3D3D3D3D3D0A0A20202020202020206372656174654373734465636C61726174696F6E733A2066756E6374696F6E2829207B0A0A202020';
wwv_flow_api.g_varchar2_table(826) := '2020202020202020202F2F2052656D6F76652070726576696F7573206373732D6465636C61726174696F6E730A20202020202020202020202024282768656164207374796C652E6A71756572792D636F6D6D656E74732D63737327292E72656D6F766528';
wwv_flow_api.g_varchar2_table(827) := '293B0A0A2020202020202020202020202F2F204E617669676174696F6E20756E6465726C696E650A202020202020202020202020746869732E63726561746543737328272E6A71756572792D636F6D6D656E747320756C2E6E617669676174696F6E206C';
wwv_flow_api.g_varchar2_table(828) := '692E6163746976653A6166746572207B6261636B67726F756E643A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F7220202B20272021696D706F7274616E743B272C0A2020202020';
wwv_flow_api.g_varchar2_table(829) := '20202020202020202020202B277D27293B0A0A2020202020202020202020202F2F2044726F70646F776E2061637469766520656C656D656E740A202020202020202020202020746869732E63726561746543737328272E6A71756572792D636F6D6D656E';
wwv_flow_api.g_varchar2_table(830) := '747320756C2E6E617669676174696F6E20756C2E64726F70646F776E206C692E616374697665207B6261636B67726F756E643A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F7220';
wwv_flow_api.g_varchar2_table(831) := '202B20272021696D706F7274616E743B272C0A202020202020202020202020202020202B277D27293B0A0A2020202020202020202020202F2F204261636B67726F756E6420686967686C696768740A202020202020202020202020746869732E63726561';
wwv_flow_api.g_varchar2_table(832) := '746543737328272E6A71756572792D636F6D6D656E7473202E686967686C696768742D6261636B67726F756E64207B6261636B67726F756E643A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C696768';
wwv_flow_api.g_varchar2_table(833) := '74436F6C6F7220202B20272021696D706F7274616E743B272C0A202020202020202020202020202020202B277D27293B0A0A2020202020202020202020202F2F20466F6E7420686967686C696768740A202020202020202020202020746869732E637265';
wwv_flow_api.g_varchar2_table(834) := '61746543737328272E6A71756572792D636F6D6D656E7473202E686967686C696768742D666F6E74207B636F6C6F723A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F72202B2027';
wwv_flow_api.g_varchar2_table(835) := '2021696D706F7274616E743B270A202020202020202020202020202020202B277D27293B0A202020202020202020202020746869732E63726561746543737328272E6A71756572792D636F6D6D656E7473202E686967686C696768742D666F6E742D626F';
wwv_flow_api.g_varchar2_table(836) := '6C64207B636F6C6F723A20270A202020202020202020202020202020202B20746869732E6F7074696F6E732E686967686C69676874436F6C6F72202B20272021696D706F7274616E743B270A202020202020202020202020202020202B2027666F6E742D';
wwv_flow_api.g_varchar2_table(837) := '7765696768743A20626F6C643B270A202020202020202020202020202020202B277D27293B0A20202020202020207D2C0A0A20202020202020206372656174654373733A2066756E6374696F6E2863737329207B0A202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(838) := '207374796C65456C203D202428273C7374796C652F3E272C207B0A20202020202020202020202020202020747970653A2027746578742F637373272C0A2020202020202020202020202020202027636C617373273A20276A71756572792D636F6D6D656E';
wwv_flow_api.g_varchar2_table(839) := '74732D637373272C0A20202020202020202020202020202020746578743A206373730A2020202020202020202020207D293B0A2020202020202020202020202428276865616427292E617070656E64287374796C65456C293B0A20202020202020207D2C';
wwv_flow_api.g_varchar2_table(840) := '0A0A0A20202020202020202F2F205574696C69746965730A20202020202020202F2F203D3D3D3D3D3D3D3D3D0A0A2020202020202020676574436F6D6D656E74733A2066756E6374696F6E2829207B0A2020202020202020202020207661722073656C66';
wwv_flow_api.g_varchar2_table(841) := '203D20746869733B0A20202020202020202020202072657475726E204F626A6563742E6B65797328746869732E636F6D6D656E747342794964292E6D61702866756E6374696F6E286964297B72657475726E2073656C662E636F6D6D656E747342794964';
wwv_flow_api.g_varchar2_table(842) := '5B69645D7D293B0A20202020202020207D2C0A0A20202020202020206765744368696C64436F6D6D656E74733A2066756E6374696F6E28706172656E74496429207B0A20202020202020202020202072657475726E20746869732E676574436F6D6D656E';
wwv_flow_api.g_varchar2_table(843) := '747328292E66696C7465722866756E6374696F6E28636F6D6D656E74297B72657475726E20636F6D6D656E742E706172656E74203D3D20706172656E7449647D293B0A20202020202020207D2C0A0A20202020202020206765744174746163686D656E74';
wwv_flow_api.g_varchar2_table(844) := '733A2066756E6374696F6E2829207B0A20202020202020202020202072657475726E20746869732E676574436F6D6D656E747328292E66696C7465722866756E6374696F6E28636F6D6D656E74297B72657475726E20636F6D6D656E742E686173417474';
wwv_flow_api.g_varchar2_table(845) := '6163686D656E747328297D293B0A20202020202020207D2C0A0A20202020202020206765744F757465726D6F7374506172656E743A2066756E6374696F6E28646972656374506172656E74496429207B0A20202020202020202020202076617220706172';
wwv_flow_api.g_varchar2_table(846) := '656E744964203D20646972656374506172656E7449643B0A202020202020202020202020646F207B0A2020202020202020202020202020202076617220706172656E74436F6D6D656E74203D20746869732E636F6D6D656E7473427949645B706172656E';
wwv_flow_api.g_varchar2_table(847) := '7449645D3B0A20202020202020202020202020202020706172656E744964203D20706172656E74436F6D6D656E742E706172656E743B0A2020202020202020202020207D207768696C6528706172656E74436F6D6D656E742E706172656E7420213D206E';
wwv_flow_api.g_varchar2_table(848) := '756C6C293B0A20202020202020202020202072657475726E20706172656E74436F6D6D656E743B0A20202020202020207D2C0A0A2020202020202020637265617465436F6D6D656E744A534F4E3A2066756E6374696F6E28636F6D6D656E74696E674669';
wwv_flow_api.g_varchar2_table(849) := '656C6429207B0A202020202020202020202020766172207465787461726561203D20636F6D6D656E74696E674669656C642E66696E6428272E746578746172656127293B0A2020202020202020202020207661722074696D65203D206E65772044617465';
wwv_flow_api.g_varchar2_table(850) := '28292E746F49534F537472696E6728293B0A0A20202020202020202020202076617220636F6D6D656E744A534F4E203D207B0A2020202020202020202020202020202069643A20276327202B202028746869732E676574436F6D6D656E747328292E6C65';
wwv_flow_api.g_varchar2_table(851) := '6E677468202B2031292C2020202F2F2054656D706F726172792069640A20202020202020202020202020202020706172656E743A2074657874617265612E617474722827646174612D706172656E742729207C7C206E756C6C2C0A202020202020202020';
wwv_flow_api.g_varchar2_table(852) := '20202020202020637265617465643A2074696D652C0A202020202020202020202020202020206D6F6469666965643A2074696D652C0A20202020202020202020202020202020636F6E74656E743A20746869732E6765745465787461726561436F6E7465';
wwv_flow_api.g_varchar2_table(853) := '6E74287465787461726561292C0A2020202020202020202020202020202070696E67733A20746869732E67657450696E6773287465787461726561292C0A2020202020202020202020202020202066756C6C6E616D653A20746869732E6F7074696F6E73';
wwv_flow_api.g_varchar2_table(854) := '2E74657874466F726D617474657228746869732E6F7074696F6E732E796F7554657874292C0A2020202020202020202020202020202070726F66696C655069637475726555524C3A20746869732E6F7074696F6E732E70726F66696C6550696374757265';
wwv_flow_api.g_varchar2_table(855) := '55524C2C0A2020202020202020202020202020202063726561746564427943757272656E74557365723A20747275652C0A202020202020202020202020202020207570766F7465436F756E743A20302C0A20202020202020202020202020202020757365';
wwv_flow_api.g_varchar2_table(856) := '724861735570766F7465643A2066616C73652C0A202020202020202020202020202020206174746163686D656E74733A20746869732E6765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C6428636F6D6D656E74696E674669';
wwv_flow_api.g_varchar2_table(857) := '656C64290A2020202020202020202020207D3B0A20202020202020202020202072657475726E20636F6D6D656E744A534F4E3B0A20202020202020207D2C0A0A20202020202020206973416C6C6F776564546F44656C6574653A2066756E6374696F6E28';
wwv_flow_api.g_varchar2_table(858) := '636F6D6D656E74496429207B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C6544656C6574696E6729207B0A20202020202020202020202020202020766172206973416C6C6F776564546F44656C657465203D2074';
wwv_flow_api.g_varchar2_table(859) := '7275653B0A2020202020202020202020202020202069662821746869732E6F7074696F6E732E656E61626C6544656C6574696E67436F6D6D656E74576974685265706C69657329207B0A2020202020202020202020202020202020202020242874686973';
wwv_flow_api.g_varchar2_table(860) := '2E676574436F6D6D656E74732829292E656163682866756E6374696F6E28696E6465782C20636F6D6D656E7429207B0A202020202020202020202020202020202020202020202020696628636F6D6D656E742E706172656E74203D3D20636F6D6D656E74';
wwv_flow_api.g_varchar2_table(861) := '496429206973416C6C6F776564546F44656C657465203D2066616C73653B0A20202020202020202020202020202020202020207D293B0A202020202020202020202020202020207D0A2020202020202020202020202020202072657475726E206973416C';
wwv_flow_api.g_varchar2_table(862) := '6C6F776564546F44656C6574653B0A2020202020202020202020207D0A20202020202020202020202072657475726E2066616C73653B0A20202020202020207D2C0A0A2020202020202020736574546F67676C65416C6C427574746F6E546578743A2066';
wwv_flow_api.g_varchar2_table(863) := '756E6374696F6E28746F67676C65416C6C427574746F6E2C20746F67676C6529207B0A2020202020202020202020207661722073656C66203D20746869733B0A2020202020202020202020207661722074657874436F6E7461696E6572203D20746F6767';
wwv_flow_api.g_varchar2_table(864) := '6C65416C6C427574746F6E2E66696E6428277370616E2E7465787427293B0A202020202020202020202020766172206361726574203D20746F67676C65416C6C427574746F6E2E66696E6428272E636172657427293B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(865) := '7661722073686F77457870616E64696E6754657874203D2066756E6374696F6E2829207B0A202020202020202020202020202020207661722074657874203D2073656C662E6F7074696F6E732E74657874466F726D61747465722873656C662E6F707469';
wwv_flow_api.g_varchar2_table(866) := '6F6E732E76696577416C6C5265706C69657354657874293B0A20202020202020202020202020202020766172207265706C79436F756E74203D20746F67676C65416C6C427574746F6E2E7369626C696E677328272E636F6D6D656E7427292E6E6F742827';
wwv_flow_api.g_varchar2_table(867) := '2E68696464656E27292E6C656E6774683B0A2020202020202020202020202020202074657874203D20746578742E7265706C61636528275F5F7265706C79436F756E745F5F272C207265706C79436F756E74293B0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(868) := '2074657874436F6E7461696E65722E746578742874657874293B0A2020202020202020202020207D3B0A0A20202020202020202020202076617220686964655265706C69657354657874203D20746869732E6F7074696F6E732E74657874466F726D6174';
wwv_flow_api.g_varchar2_table(869) := '74657228746869732E6F7074696F6E732E686964655265706C69657354657874293B0A0A202020202020202020202020696628746F67676C6529207B0A0A202020202020202020202020202020202F2F20546F67676C6520746578740A20202020202020';
wwv_flow_api.g_varchar2_table(870) := '20202020202020202069662874657874436F6E7461696E65722E746578742829203D3D20686964655265706C6965735465787429207B0A202020202020202020202020202020202020202073686F77457870616E64696E675465787428293B0A20202020';
wwv_flow_api.g_varchar2_table(871) := '2020202020202020202020207D20656C7365207B0A202020202020202020202020202020202020202074657874436F6E7461696E65722E7465787428686964655265706C69657354657874293B0A202020202020202020202020202020207D0A20202020';
wwv_flow_api.g_varchar2_table(872) := '2020202020202020202020202F2F20546F67676C6520646972656374696F6E206F66207468652063617265740A2020202020202020202020202020202063617265742E746F67676C65436C6173732827757027293B0A0A2020202020202020202020207D';
wwv_flow_api.g_varchar2_table(873) := '20656C7365207B0A0A202020202020202020202020202020202F2F205570646174652074657874206966206E65636573736172790A2020202020202020202020202020202069662874657874436F6E7461696E65722E74657874282920213D2068696465';
wwv_flow_api.g_varchar2_table(874) := '5265706C6965735465787429207B0A202020202020202020202020202020202020202073686F77457870616E64696E675465787428293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D2C0A0A';
wwv_flow_api.g_varchar2_table(875) := '2020202020202020736574427574746F6E53746174653A2066756E6374696F6E28627574746F6E2C20656E61626C65642C206C6F6164696E6729207B0A202020202020202020202020627574746F6E2E746F67676C65436C6173732827656E61626C6564';
wwv_flow_api.g_varchar2_table(876) := '272C20656E61626C6564293B0A2020202020202020202020206966286C6F6164696E6729207B0A20202020202020202020202020202020627574746F6E2E68746D6C28746869732E6372656174655370696E6E6572287472756529293B0A202020202020';
wwv_flow_api.g_varchar2_table(877) := '2020202020207D20656C7365207B0A20202020202020202020202020202020627574746F6E2E68746D6C28627574746F6E2E6461746128276F726967696E616C2D636F6E74656E742729293B0A2020202020202020202020207D0A20202020202020207D';
wwv_flow_api.g_varchar2_table(878) := '2C0A0A202020202020202061646A75737454657874617265614865696768743A2066756E6374696F6E2874657874617265612C20666F63757329207B0A20202020202020202020202076617220746578746172656142617365486569676874203D20322E';
wwv_flow_api.g_varchar2_table(879) := '323B0A202020202020202020202020766172206C696E65486569676874203D20312E34353B0A0A20202020202020202020202076617220736574526F7773203D2066756E6374696F6E28726F777329207B0A202020202020202020202020202020207661';
wwv_flow_api.g_varchar2_table(880) := '7220686569676874203D20746578746172656142617365486569676874202B2028726F7773202D203129202A206C696E654865696768743B0A2020202020202020202020202020202074657874617265612E6373732827686569676874272C2068656967';
wwv_flow_api.g_varchar2_table(881) := '6874202B2027656D27293B0A2020202020202020202020207D3B0A0A2020202020202020202020207465787461726561203D2024287465787461726561293B0A20202020202020202020202076617220726F77436F756E74203D20666F637573203D3D20';
wwv_flow_api.g_varchar2_table(882) := '74727565203F20746869732E6F7074696F6E732E7465787461726561526F77734F6E466F637573203A20746869732E6F7074696F6E732E7465787461726561526F77733B0A202020202020202020202020646F207B0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(883) := '2020736574526F777328726F77436F756E74293B0A20202020202020202020202020202020726F77436F756E742B2B3B0A20202020202020202020202020202020766172206973417265615363726F6C6C61626C65203D2074657874617265615B305D2E';
wwv_flow_api.g_varchar2_table(884) := '7363726F6C6C486569676874203E2074657874617265612E6F7574657248656967687428293B0A20202020202020202020202020202020766172206D6178526F777355736564203D20746869732E6F7074696F6E732E74657874617265614D6178526F77';
wwv_flow_api.g_varchar2_table(885) := '73203D3D2066616C7365203F0A202020202020202020202020202020202020202066616C7365203A20726F77436F756E74203E20746869732E6F7074696F6E732E74657874617265614D6178526F77733B0A2020202020202020202020207D207768696C';
wwv_flow_api.g_varchar2_table(886) := '65286973417265615363726F6C6C61626C6520262620216D6178526F777355736564293B0A20202020202020207D2C0A0A2020202020202020636C65617254657874617265613A2066756E6374696F6E28746578746172656129207B0A20202020202020';
wwv_flow_api.g_varchar2_table(887) := '202020202074657874617265612E656D70747928292E747269676765722827696E70757427293B0A20202020202020207D2C0A0A20202020202020206765745465787461726561436F6E74656E743A2066756E6374696F6E2874657874617265612C2068';
wwv_flow_api.g_varchar2_table(888) := '756D616E5265616461626C6529207B0A202020202020202020202020766172207465787461726561436C6F6E65203D2074657874617265612E636C6F6E6528293B0A0A2020202020202020202020202F2F2052656D6F7665207265706C792D746F207461';
wwv_flow_api.g_varchar2_table(889) := '670A2020202020202020202020207465787461726561436C6F6E652E66696E6428272E7265706C792D746F2E74616727292E72656D6F766528293B0A0A2020202020202020202020202F2F205265706C6163652074616773207769746820746578742076';
wwv_flow_api.g_varchar2_table(890) := '616C7565730A2020202020202020202020207465787461726561436C6F6E652E66696E6428272E7461672E6861736874616727292E7265706C616365576974682866756E6374696F6E28297B0A2020202020202020202020202020202072657475726E20';
wwv_flow_api.g_varchar2_table(891) := '68756D616E5265616461626C65203F20242874686973292E76616C2829203A20272327202B20242874686973292E617474722827646174612D76616C756527293B0A2020202020202020202020207D293B0A202020202020202020202020746578746172';
wwv_flow_api.g_varchar2_table(892) := '6561436C6F6E652E66696E6428272E7461672E70696E6727292E7265706C616365576974682866756E6374696F6E28297B0A2020202020202020202020202020202072657475726E2068756D616E5265616461626C65203F20242874686973292E76616C';
wwv_flow_api.g_varchar2_table(893) := '2829203A20274027202B20242874686973292E617474722827646174612D76616C756527293B0A2020202020202020202020207D293B0A0A202020202020202020202020766172206365203D202428273C7072652F3E27292E68746D6C28746578746172';
wwv_flow_api.g_varchar2_table(894) := '6561436C6F6E652E68746D6C2829293B0A20202020202020202020202063652E66696E6428276469762C20702C20627227292E7265706C616365576974682866756E6374696F6E2829207B2072657475726E20275C6E27202B20746869732E696E6E6572';
wwv_flow_api.g_varchar2_table(895) := '48544D4C3B207D293B0A0A2020202020202020202020202F2F205472696D206C656164696E67207370616365730A2020202020202020202020207661722074657874203D2063652E7465787428292E7265706C616365282F5E5C732B2F672C202727293B';
wwv_flow_api.g_varchar2_table(896) := '0A0A2020202020202020202020202F2F204E6F726D616C697A65207370616365730A2020202020202020202020207661722074657874203D20746869732E6E6F726D616C697A655370616365732874657874293B0A202020202020202020202020726574';
wwv_flow_api.g_varchar2_table(897) := '75726E20746578743B0A20202020202020207D2C0A0A2020202020202020676574466F726D6174746564436F6D6D656E74436F6E74656E743A2066756E6374696F6E28636F6D6D656E744D6F64656C2C207265706C6163654E65774C696E657329207B0A';
wwv_flow_api.g_varchar2_table(898) := '2020202020202020202020207661722068746D6C203D20746869732E65736361706528636F6D6D656E744D6F64656C2E636F6E74656E74293B0A20202020202020202020202068746D6C203D20746869732E6C696E6B6966792868746D6C293B0A202020';
wwv_flow_api.g_varchar2_table(899) := '20202020202020202068746D6C203D20746869732E686967686C696768745461677328636F6D6D656E744D6F64656C2C2068746D6C293B0A2020202020202020202020206966287265706C6163654E65774C696E6573292068746D6C203D2068746D6C2E';
wwv_flow_api.g_varchar2_table(900) := '7265706C616365282F283F3A5C6E292F672C20273C62723E27293B0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A20202020202020202F2F2052657475726E2070696E677320696E20666F726D61740A20';
wwv_flow_api.g_varchar2_table(901) := '202020202020202F2F20207B0A20202020202020202F2F2020202020206964313A207573657246756C6C6E616D65312C0A20202020202020202F2F2020202020206964323A207573657246756C6C6E616D65322C0A20202020202020202F2F2020202020';
wwv_flow_api.g_varchar2_table(902) := '202E2E2E0A20202020202020202F2F20207D0A202020202020202067657450696E67733A2066756E6374696F6E28746578746172656129207B0A2020202020202020202020207661722070696E6773203D207B7D3B0A2020202020202020202020207465';
wwv_flow_api.g_varchar2_table(903) := '7874617265612E66696E6428272E70696E6727292E656163682866756E6374696F6E28696E6465782C20656C297B0A20202020202020202020202020202020766172206964203D207061727365496E74282428656C292E617474722827646174612D7661';
wwv_flow_api.g_varchar2_table(904) := '6C75652729293B0A202020202020202020202020202020207661722076616C7565203D202428656C292E76616C28293B0A2020202020202020202020202020202070696E67735B69645D203D2076616C75652E736C6963652831293B0A20202020202020';
wwv_flow_api.g_varchar2_table(905) := '20202020207D293B0A20202020202020202020202072657475726E2070696E67733B0A20202020202020207D2C0A0A20202020202020206765744174746163686D656E747346726F6D436F6D6D656E74696E674669656C643A2066756E6374696F6E2863';
wwv_flow_api.g_varchar2_table(906) := '6F6D6D656E74696E674669656C6429207B0A202020202020202020202020766172206174746163686D656E7473203D20636F6D6D656E74696E674669656C642E66696E6428272E6174746163686D656E7473202E6174746163686D656E7427292E6D6170';
wwv_flow_api.g_varchar2_table(907) := '2866756E6374696F6E28297B0A2020202020202020202020202020202072657475726E20242874686973292E6461746128293B0A2020202020202020202020207D292E746F417272617928293B0A0A20202020202020202020202072657475726E206174';
wwv_flow_api.g_varchar2_table(908) := '746163686D656E74733B0A20202020202020207D2C0A0A20202020202020206D6F7665437572736F72546F456E643A2066756E6374696F6E28656C29207B0A202020202020202020202020656C203D202428656C295B305D3B0A0A202020202020202020';
wwv_flow_api.g_varchar2_table(909) := '2020202F2F205472696767657220696E70757420746F2061646A7573742073697A650A2020202020202020202020202428656C292E747269676765722827696E70757427293B0A0A2020202020202020202020202F2F205363726F6C6C20746F20626F74';
wwv_flow_api.g_varchar2_table(910) := '746F6D0A2020202020202020202020202428656C292E7363726F6C6C546F7028656C2E7363726F6C6C486569676874293B0A0A2020202020202020202020202F2F204D6F766520637572736F7220746F20656E640A202020202020202020202020696620';
wwv_flow_api.g_varchar2_table(911) := '28747970656F662077696E646F772E67657453656C656374696F6E20213D2027756E646566696E65642720262620747970656F6620646F63756D656E742E63726561746552616E676520213D2027756E646566696E65642729207B0A2020202020202020';
wwv_flow_api.g_varchar2_table(912) := '20202020202020207661722072616E6765203D20646F63756D656E742E63726561746552616E676528293B0A2020202020202020202020202020202072616E67652E73656C6563744E6F6465436F6E74656E747328656C293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(913) := '20202020202072616E67652E636F6C6C617073652866616C7365293B0A202020202020202020202020202020207661722073656C203D2077696E646F772E67657453656C656374696F6E28293B0A2020202020202020202020202020202073656C2E7265';
wwv_flow_api.g_varchar2_table(914) := '6D6F7665416C6C52616E67657328293B0A2020202020202020202020202020202073656C2E61646452616E67652872616E6765293B0A2020202020202020202020207D20656C73652069662028747970656F6620646F63756D656E742E626F64792E6372';
wwv_flow_api.g_varchar2_table(915) := '656174655465787452616E676520213D2027756E646566696E65642729207B0A20202020202020202020202020202020766172207465787452616E6765203D20646F63756D656E742E626F64792E6372656174655465787452616E676528293B0A202020';
wwv_flow_api.g_varchar2_table(916) := '202020202020202020202020207465787452616E67652E6D6F7665546F456C656D656E745465787428656C293B0A202020202020202020202020202020207465787452616E67652E636F6C6C617073652866616C7365293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(917) := '20202020207465787452616E67652E73656C65637428293B0A2020202020202020202020207D0A0A2020202020202020202020202F2F20466F6375730A202020202020202020202020656C2E666F63757328293B0A20202020202020207D2C0A0A202020';
wwv_flow_api.g_varchar2_table(918) := '2020202020656E73757265456C656D656E74537461797356697369626C653A2066756E6374696F6E28656C29207B0A202020202020202020202020766172206D61785363726F6C6C546F70203D20656C2E706F736974696F6E28292E746F703B0A202020';
wwv_flow_api.g_varchar2_table(919) := '202020202020202020766172206D696E5363726F6C6C546F70203D20656C2E706F736974696F6E28292E746F70202B20656C2E6F757465724865696768742829202D20746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E6F757465';
wwv_flow_api.g_varchar2_table(920) := '7248656967687428293B0A0A2020202020202020202020202F2F20436173653A20656C656D656E742068696464656E2061626F76652073636F6C6C20617265610A202020202020202020202020696628746869732E6F7074696F6E732E7363726F6C6C43';
wwv_flow_api.g_varchar2_table(921) := '6F6E7461696E65722E7363726F6C6C546F702829203E206D61785363726F6C6C546F7029207B0A20202020202020202020202020202020746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F70286D6178536372';
wwv_flow_api.g_varchar2_table(922) := '6F6C6C546F70293B0A0A2020202020202020202020202F2F20436173653A20656C656D656E742068696464656E2062656C6F772073636F6C6C20617265610A2020202020202020202020207D20656C736520696628746869732E6F7074696F6E732E7363';
wwv_flow_api.g_varchar2_table(923) := '726F6C6C436F6E7461696E65722E7363726F6C6C546F702829203C206D696E5363726F6C6C546F7029207B0A20202020202020202020202020202020746869732E6F7074696F6E732E7363726F6C6C436F6E7461696E65722E7363726F6C6C546F70286D';
wwv_flow_api.g_varchar2_table(924) := '696E5363726F6C6C546F70293B0A2020202020202020202020207D0A0A20202020202020207D2C0A0A20202020202020206573636170653A2066756E6374696F6E28696E7075745465787429207B0A20202020202020202020202072657475726E202428';
wwv_flow_api.g_varchar2_table(925) := '273C7072652F3E27292E7465787428746869732E6E6F726D616C697A6553706163657328696E7075745465787429292E68746D6C28293B0A20202020202020207D2C0A0A20202020202020206E6F726D616C697A655370616365733A2066756E6374696F';
wwv_flow_api.g_varchar2_table(926) := '6E28696E7075745465787429207B0A20202020202020202020202072657475726E20696E707574546578742E7265706C616365286E65772052656745787028275C7530306130272C20276727292C20272027293B2020202F2F20436F6E76657274206E6F';
wwv_flow_api.g_varchar2_table(927) := '6E2D627265616B696E672073706163657320746F20726567756172207370616365730A20202020202020207D2C0A0A202020202020202061667465723A2066756E6374696F6E2874696D65732C2066756E6329207B0A2020202020202020202020207661';
wwv_flow_api.g_varchar2_table(928) := '722073656C66203D20746869733B0A20202020202020202020202072657475726E2066756E6374696F6E2829207B0A2020202020202020202020202020202074696D65732D2D3B0A202020202020202020202020202020206966202874696D6573203D3D';
wwv_flow_api.g_varchar2_table(929) := '203029207B0A202020202020202020202020202020202020202072657475726E2066756E632E6170706C792873656C662C20617267756D656E7473293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A202020202020';
wwv_flow_api.g_varchar2_table(930) := '20207D2C0A0A2020202020202020686967686C69676874546167733A2066756E6374696F6E28636F6D6D656E744D6F64656C2C2068746D6C29207B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C65486173687461';
wwv_flow_api.g_varchar2_table(931) := '6773292068746D6C203D20746869732E686967686C69676874486173687461677328636F6D6D656E744D6F64656C2C2068746D6C293B0A202020202020202020202020696628746869732E6F7074696F6E732E656E61626C6550696E67696E6729206874';
wwv_flow_api.g_varchar2_table(932) := '6D6C203D20746869732E686967686C6967687450696E677328636F6D6D656E744D6F64656C2C2068746D6C293B0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A2020202020202020686967686C69676874';
wwv_flow_api.g_varchar2_table(933) := '48617368746167733A2066756E6374696F6E28636F6D6D656E744D6F64656C2C2068746D6C29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202069662868746D6C2E696E6465784F662827';
wwv_flow_api.g_varchar2_table(934) := '23272920213D202D3129207B0A0A20202020202020202020202020202020766172205F5F637265617465546167203D2066756E6374696F6E2874616729207B0A202020202020202020202020202020202020202076617220746167203D2073656C662E63';
wwv_flow_api.g_varchar2_table(935) := '7265617465546167456C656D656E7428272327202B207461672C202768617368746167272C20746167293B0A202020202020202020202020202020202020202072657475726E207461675B305D2E6F7574657248544D4C3B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(936) := '20202020207D0A0A20202020202020202020202020202020766172207265676578203D202F285E7C5C732923285B612D7A5C75303043302D5C75303046465C642D5F5D2B292F67696D3B0A2020202020202020202020202020202068746D6C203D206874';
wwv_flow_api.g_varchar2_table(937) := '6D6C2E7265706C6163652872656765782C2066756E6374696F6E2824302C2024312C202432297B0A202020202020202020202020202020202020202072657475726E202431202B205F5F637265617465546167282432293B0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(938) := '20202020207D293B0A2020202020202020202020207D0A20202020202020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A2020202020202020686967686C6967687450696E67733A2066756E6374696F6E28636F6D6D656E74';
wwv_flow_api.g_varchar2_table(939) := '4D6F64656C2C2068746D6C29207B0A2020202020202020202020207661722073656C66203D20746869733B0A0A20202020202020202020202069662868746D6C2E696E6465784F66282740272920213D202D3129207B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(940) := '20202020766172205F5F637265617465546167203D2066756E6374696F6E2870696E67546578742C2075736572496429207B0A202020202020202020202020202020202020202076617220746167203D2073656C662E637265617465546167456C656D65';
wwv_flow_api.g_varchar2_table(941) := '6E742870696E67546578742C202770696E67272C207573657249642C207B0A20202020202020202020202020202020202020202020202027646174612D757365722D6964273A207573657249640A20202020202020202020202020202020202020207D29';
wwv_flow_api.g_varchar2_table(942) := '3B0A202020202020202020202020202020202020202072657475726E207461675B305D2E6F7574657248544D4C3B0A202020202020202020202020202020207D0A0A2020202020202020202020202020202024284F626A6563742E6B65797328636F6D6D';
wwv_flow_api.g_varchar2_table(943) := '656E744D6F64656C2E70696E677329292E656163682866756E6374696F6E28696E6465782C2075736572496429207B0A20202020202020202020202020202020202020207661722066756C6C6E616D65203D20636F6D6D656E744D6F64656C2E70696E67';
wwv_flow_api.g_varchar2_table(944) := '735B7573657249645D3B0A20202020202020202020202020202020202020207661722070696E6754657874203D20274027202B2066756C6C6E616D653B0A202020202020202020202020202020202020202068746D6C203D2068746D6C2E7265706C6163';
wwv_flow_api.g_varchar2_table(945) := '65286E6577205265674578702870696E67546578742C20276727292C205F5F6372656174655461672870696E67546578742C2075736572496429293B0A202020202020202020202020202020207D293B0A2020202020202020202020207D0A2020202020';
wwv_flow_api.g_varchar2_table(946) := '2020202020202072657475726E2068746D6C3B0A20202020202020207D2C0A0A20202020202020206C696E6B6966793A2066756E6374696F6E28696E7075745465787429207B0A202020202020202020202020766172207265706C61636564546578742C';
wwv_flow_api.g_varchar2_table(947) := '207265706C6163655061747465726E312C207265706C6163655061747465726E322C207265706C6163655061747465726E333B0A0A2020202020202020202020202F2F2055524C73207374617274696E67207769746820687474703A2F2F2C2068747470';
wwv_flow_api.g_varchar2_table(948) := '733A2F2F2C206674703A2F2F206F722066696C653A2F2F0A2020202020202020202020207265706C6163655061747465726E31203D202F285C622868747470733F7C6674707C66696C65293A5C2F5C2F5B2D412D5AC384C396C385302D392B2640235C2F';
wwv_flow_api.g_varchar2_table(949) := '253F3D7E5F7C213A2C2E3B7B7D5D2A5B2D412D5AC384C396C385302D392B2640235C2F253D7E5F7C7B7D5D292F67696D3B0A2020202020202020202020207265706C6163656454657874203D20696E707574546578742E7265706C616365287265706C61';
wwv_flow_api.g_varchar2_table(950) := '63655061747465726E312C20273C6120687265663D22243122207461726765743D225F626C616E6B223E24313C2F613E27293B0A0A2020202020202020202020202F2F2055524C73207374617274696E67207769746820227777772E222028776974686F';
wwv_flow_api.g_varchar2_table(951) := '7574202F2F206265666F72652069742C206F7220697420776F756C642072652D6C696E6B20746865206F6E657320646F6E652061626F7665292E0A2020202020202020202020207265706C6163655061747465726E32203D202F285E7C5B5E5C2F665D29';
wwv_flow_api.g_varchar2_table(952) := '287777775C2E5B2D412D5AC384C396C385302D392B2640235C2F253F3D7E5F7C213A2C2E3B7B7D5D2A5B2D412D5AC384C396C385302D392B2640235C2F253D7E5F7C7B7D5D292F67696D3B0A2020202020202020202020207265706C6163656454657874';
wwv_flow_api.g_varchar2_table(953) := '203D207265706C61636564546578742E7265706C616365287265706C6163655061747465726E322C202724313C6120687265663D2268747470733A2F2F243222207461726765743D225F626C616E6B223E24323C2F613E27293B0A0A2020202020202020';
wwv_flow_api.g_varchar2_table(954) := '202020202F2F204368616E676520656D61696C2061646472657373657320746F206D61696C746F3A206C696E6B732E0A2020202020202020202020207265706C6163655061747465726E33203D202F28285B412D5AC384C396C385302D395C2D5C5F5C2E';
wwv_flow_api.g_varchar2_table(955) := '5D292B405B412D5AC384C396C3855C5F5D2B3F285C2E5B412D5AC384C396C3855D7B322C367D292B292F67696D3B0A2020202020202020202020207265706C6163656454657874203D207265706C61636564546578742E7265706C616365287265706C61';
wwv_flow_api.g_varchar2_table(956) := '63655061747465726E332C20273C6120687265663D226D61696C746F3A243122207461726765743D225F626C616E6B223E24313C2F613E27293B0A0A2020202020202020202020202F2F2049662074686572652061726520687265667320696E20746865';
wwv_flow_api.g_varchar2_table(957) := '206F726967696E616C20746578742C206C657427732073706C69740A2020202020202020202020202F2F20746865207465787420757020616E64206F6E6C7920776F726B206F6E20746865207061727473207468617420646F6E27742068617665207572';
wwv_flow_api.g_varchar2_table(958) := '6C73207965742E0A20202020202020202020202076617220636F756E74203D20696E707574546578742E6D61746368282F3C6120687265662F6729207C7C205B5D3B0A0A20202020202020202020202069662028636F756E742E6C656E677468203E2030';
wwv_flow_api.g_varchar2_table(959) := '29207B0A202020202020202020202020202020202F2F204B6565702064656C696D69746572207768656E2073706C697474696E670A202020202020202020202020202020207661722073706C6974496E707574203D20696E707574546578742E73706C69';
wwv_flow_api.g_varchar2_table(960) := '74282F283C5C2F613E292F67293B0A20202020202020202020202020202020666F7220287661722069203D2030203B2069203C2073706C6974496E7075742E6C656E677468203B20692B2B29207B0A202020202020202020202020202020202020202069';
wwv_flow_api.g_varchar2_table(961) := '66202873706C6974496E7075745B695D2E6D61746368282F3C6120687265662F6729203D3D206E756C6C29207B0A20202020202020202020202020202020202020202020202073706C6974496E7075745B695D203D2073706C6974496E7075745B695D0A';
wwv_flow_api.g_varchar2_table(962) := '202020202020202020202020202020202020202020202020202020202E7265706C616365287265706C6163655061747465726E312C20273C6120687265663D22243122207461726765743D225F626C616E6B223E24313C2F613E27290A20202020202020';
wwv_flow_api.g_varchar2_table(963) := '2020202020202020202020202020202020202020202E7265706C616365287265706C6163655061747465726E322C202724313C6120687265663D2268747470733A2F2F243222207461726765743D225F626C616E6B223E24323C2F613E27290A20202020';
wwv_flow_api.g_varchar2_table(964) := '2020202020202020202020202020202020202020202020202E7265706C616365287265706C6163655061747465726E332C20273C6120687265663D226D61696C746F3A243122207461726765743D225F626C616E6B223E24313C2F613E27293B0A202020';
wwv_flow_api.g_varchar2_table(965) := '20202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020202020202076617220636F6D62696E65645265706C6163656454657874203D2073706C6974496E7075742E6A6F696E282727293B';
wwv_flow_api.g_varchar2_table(966) := '0A2020202020202020202020202020202072657475726E20636F6D62696E65645265706C61636564546578743B0A2020202020202020202020207D20656C7365207B0A2020202020202020202020202020202072657475726E207265706C616365645465';
wwv_flow_api.g_varchar2_table(967) := '78743B0A2020202020202020202020207D0A20202020202020207D2C0A0A202020202020202077616974556E74696C3A2066756E6374696F6E28636F6E646974696F6E2C2063616C6C6261636B29207B0A2020202020202020202020207661722073656C';
wwv_flow_api.g_varchar2_table(968) := '66203D20746869733B0A0A202020202020202020202020696628636F6E646974696F6E282929207B0A2020202020202020202020202020202063616C6C6261636B28293B0A2020202020202020202020207D20656C7365207B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(969) := '20202020202073657454696D656F75742866756E6374696F6E2829207B0A202020202020202020202020202020202020202073656C662E77616974556E74696C28636F6E646974696F6E2C2063616C6C6261636B293B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(970) := '2020207D2C20313030293B0A2020202020202020202020207D0A20202020202020207D2C0A0A2020202020202020617265417272617973457175616C3A2066756E6374696F6E286172726179312C2061727261793229207B0A0A20202020202020202020';
wwv_flow_api.g_varchar2_table(971) := '20202F2F20436173653A206172726179732061726520646966666572656E742073697A65640A2020202020202020202020206966286172726179312E6C656E67746820213D206172726179322E6C656E67746829207B0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(972) := '20202072657475726E2066616C73653B0A0A2020202020202020202020202F2F20436173653A206172726179732061726520657175616C2073697A65640A2020202020202020202020207D20656C7365207B0A2020202020202020202020202020202061';
wwv_flow_api.g_varchar2_table(973) := '72726179312E736F727428293B0A202020202020202020202020202020206172726179322E736F727428293B0A0A20202020202020202020202020202020666F722876617220693D303B2069203C206172726179312E6C656E6774683B20692B2B29207B';
wwv_flow_api.g_varchar2_table(974) := '0A20202020202020202020202020202020202020206966286172726179315B695D20213D206172726179325B695D292072657475726E2066616C73653B0A202020202020202020202020202020207D0A0A20202020202020202020202020202020726574';
wwv_flow_api.g_varchar2_table(975) := '75726E20747275653B0A2020202020202020202020207D0A20202020202020207D2C0A0A20202020202020206170706C79496E7465726E616C4D617070696E67733A2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A202020202020202020';
wwv_flow_api.g_varchar2_table(976) := '2020202F2F20496E76657274696E67206669656C64206D617070696E67730A20202020202020202020202076617220696E7665727465644D617070696E6773203D207B7D3B0A202020202020202020202020766172206D617070696E6773203D20746869';
wwv_flow_api.g_varchar2_table(977) := '732E6F7074696F6E732E6669656C644D617070696E67733B0A202020202020202020202020666F7220287661722070726F7020696E206D617070696E677329207B0A202020202020202020202020202020206966286D617070696E67732E6861734F776E';
wwv_flow_api.g_varchar2_table(978) := '50726F70657274792870726F702929207B0A2020202020202020202020202020202020202020696E7665727465644D617070696E67735B6D617070696E67735B70726F705D5D203D2070726F703B0A202020202020202020202020202020207D0A202020';
wwv_flow_api.g_varchar2_table(979) := '2020202020202020207D0A0A20202020202020202020202072657475726E20746869732E6170706C794D617070696E677328696E7665727465644D617070696E67732C20636F6D6D656E744A534F4E293B0A20202020202020207D2C0A0A202020202020';
wwv_flow_api.g_varchar2_table(980) := '20206170706C7945787465726E616C4D617070696E67733A2066756E6374696F6E28636F6D6D656E744A534F4E29207B0A202020202020202020202020766172206D617070696E6773203D20746869732E6F7074696F6E732E6669656C644D617070696E';
wwv_flow_api.g_varchar2_table(981) := '67733B0A20202020202020202020202072657475726E20746869732E6170706C794D617070696E6773286D617070696E67732C20636F6D6D656E744A534F4E293B0A20202020202020207D2C0A0A20202020202020206170706C794D617070696E67733A';
wwv_flow_api.g_varchar2_table(982) := '2066756E6374696F6E286D617070696E67732C20636F6D6D656E744A534F4E29207B0A20202020202020202020202076617220726573756C74203D207B7D3B0A0A202020202020202020202020666F7228766172206B65793120696E20636F6D6D656E74';
wwv_flow_api.g_varchar2_table(983) := '4A534F4E29207B0A202020202020202020202020202020206966286B65793120696E206D617070696E677329207B0A2020202020202020202020202020202020202020766172206B657932203D206D617070696E67735B6B6579315D3B0A202020202020';
wwv_flow_api.g_varchar2_table(984) := '2020202020202020202020202020726573756C745B6B6579325D203D20636F6D6D656E744A534F4E5B6B6579315D3B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020202020202072657475726E2072';
wwv_flow_api.g_varchar2_table(985) := '6573756C743B0A20202020202020207D0A0A202020207D3B0A0A20202020242E666E2E636F6D6D656E7473203D2066756E6374696F6E286F7074696F6E7329207B0A202020202020202072657475726E20746869732E656163682866756E6374696F6E28';
wwv_flow_api.g_varchar2_table(986) := '29207B0A20202020202020202020202076617220636F6D6D656E7473203D204F626A6563742E63726561746528436F6D6D656E7473293B0A202020202020202020202020242E6461746128746869732C2027636F6D6D656E7473272C20636F6D6D656E74';
wwv_flow_api.g_varchar2_table(987) := '73293B0A202020202020202020202020636F6D6D656E74732E696E6974286F7074696F6E73207C7C207B7D2C2074686973293B0A20202020202020207D293B0A202020207D3B0A7D29293B0A';
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
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C7320617065782C24202A2F0D0A77696E646F772E434F4D4D454E5453203D2077696E646F772E434F4D4D454E5453207C7C207B7D3B0D0A0D0A434F4D4D454E54532E696E697469616C697A65203D2066756E6374696F6E28636F6E';
wwv_flow_api.g_varchar2_table(2) := '6669672C20696E697429207B0D0A2020202069662028696E697420262620747970656F6620696E6974203D3D202766756E6374696F6E2729207B0D0A2020202020202020696E69742E63616C6C28746869732C20636F6E666967293B0D0A202020207D0D';
wwv_flow_api.g_varchar2_table(3) := '0A0D0A202020202F2F696E697469616C697A652074686520636F6D6D656E74696E6720726567696F6E0D0A202020202428272327202B20636F6E6669672E66756E6374696F6E616C6974697465732E726567696F6E4964292E636F6D6D656E7473287B0D';
wwv_flow_api.g_varchar2_table(4) := '0A20202020202020202F2F66756E6374696F6E616C69746965730D0A2020202020202020676574436F6D6D656E74733A2066756E6374696F6E28737563636573732C206572726F7229207B0D0A20202020202020202020202076617220636F6D6D656E74';
wwv_flow_api.g_varchar2_table(5) := '734172726179203D20636F6E6669672E636F6D6D656E74733B0D0A2020202020202020202020207375636365737328636F6D6D656E74734172726179293B0D0A20202020202020207D2C0D0A0D0A202020202020202073656172636855736572733A2066';
wwv_flow_api.g_varchar2_table(6) := '756E6374696F6E287465726D2C20737563636573732C206572726F7229207B0D0A2020202020202020202020207375636365737328636F6E6669672E70696E67696E674C697374293B0D0A20202020202020207D2C0D0A0D0A2020202020202020706F73';
wwv_flow_api.g_varchar2_table(7) := '74436F6D6D656E743A2066756E6374696F6E28636F6D6D656E744A534F4E2C20737563636573732C206572726F7229207B0D0A202020202020202020202020636F6E736F6C652E6C6F6728636F6D6D656E744A534F4E293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(8) := '20202F2A617065782E7365727665722E706C7567696E2028206C416A61784964656E7469666965722C207B0D0A20202020202020202020202020202020202020207830313A636F6E6669672E2C0D0A202020202020202020202020202020202020202078';
wwv_flow_api.g_varchar2_table(9) := '30323A2C0D0A20202020202020202020202020202020202020207830333A2C0D0A20202020202020202020202020202020202020207830343A0D0A202020202020202020202020202020207D2A2F0D0A20202020202020207D2C0D0A0D0A202020207D29';
wwv_flow_api.g_varchar2_table(10) := '3B0D0A7D3B';
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
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22434F4D4D454E5453222C22696E697469616C697A65222C22636F6E666967222C22696E6974222C2263616C6C';
wwv_flow_api.g_varchar2_table(2) := '222C2274686973222C2224222C2266756E6374696F6E616C697469746573222C22726567696F6E4964222C22636F6D6D656E7473222C22676574436F6D6D656E7473222C2273756363657373222C226572726F72222C227365617263685573657273222C';
wwv_flow_api.g_varchar2_table(3) := '227465726D222C2270696E67696E674C697374222C22706F7374436F6D6D656E74222C22636F6D6D656E744A534F4E222C22636F6E736F6C65222C226C6F67225D2C226D617070696E6773223A2241414341412C4F41414F432C53414157442C4F41414F';
wwv_flow_api.g_varchar2_table(4) := '432C554141592C4741457243412C53414153432C574141612C53414153432C45414151432C4741432F42412C47414175422C6D42414152412C47414366412C4541414B432C4B41414B432C4B41414D482C4741497042492C454141452C4941414D4A2C45';
wwv_flow_api.g_varchar2_table(5) := '41414F4B2C694241416942432C55414155432C534141532C4341452F43432C594141612C53414153432C45414153432C4741453342442C4541446F42542C4541414F4F2C5741492F42492C594141612C53414153432C4541414D482C45414153432C4741';
wwv_flow_api.g_varchar2_table(6) := '436A43442C45414151542C4541414F612C6341476E42432C594141612C53414153432C454141614E2C45414153432C47414378434D2C51414151432C4941414946222C2266696C65223A227363726970742E6A73227D';
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
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E434F4D4D454E54533D77696E646F772E434F4D4D454E54537C7C7B7D2C434F4D4D454E54532E696E697469616C697A653D66756E6374696F6E286E2C69297B6926262266756E6374696F6E223D3D747970656F6620692626692E63616C';
wwv_flow_api.g_varchar2_table(2) := '6C28746869732C6E292C24282223222B6E2E66756E6374696F6E616C6974697465732E726567696F6E4964292E636F6D6D656E7473287B676574436F6D6D656E74733A66756E6374696F6E28692C6F297B69286E2E636F6D6D656E7473297D2C73656172';
wwv_flow_api.g_varchar2_table(3) := '636855736572733A66756E6374696F6E28692C6F2C74297B6F286E2E70696E67696E674C697374297D2C706F7374436F6D6D656E743A66756E6374696F6E286E2C692C6F297B636F6E736F6C652E6C6F67286E297D7D297D3B0A2F2F2320736F75726365';
wwv_flow_api.g_varchar2_table(4) := '4D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(41299243267025733206)
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
