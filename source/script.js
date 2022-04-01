/* globals apex,$ */
window.COMMENTS = window.COMMENTS || {};

//Initialize plugin
COMMENTS.initialize = function(config, data, init) {

    //regionid and convert pinginglist to acceptable JSON format for the API
    var regionId = data.regionId;
    var commentsWithPings = COMMENTS.addPingsJSON(data.comments,data.pingingList);

    //Initialize commenting region DOM
    config.getComments = function(success, error) {
        success(commentsWithPings);
    };

    //Search and filter user dynamically while pinging
    config.searchUsers = function(term, success, error) {
        success(COMMENTS.filterPingsList(data.pingingList,term));
    };

    //Insert new comment
    config.postComment = function(commentJSON, success, error) {

        apex.server.plugin ( data.ajaxIdentifier, {
                x01: 'I',
                x02: commentJSON.id,
                x03: commentJSON.parent,
                x04: commentJSON.content,
                x05: commentJSON.fullname,
                x06: 'INSCOMMENT',
                x07: commentJSON.profile_picture_url
        },  
        {
            success: function( data )  {
                success(commentJSON);
            },
            error: function( jqXHR, textStatus, errorThrown ) {
                apex.message.alert(jqXHR.responseJSON.message);
            }
        })
    };

    //DELETE comments and replies
    config.deleteComment = function(commentJSON, success, error) {
        //check if the comment or reply was successfully processed
        var isProcessSuccessfullyFinihed = true;

        //Deleting replies
        if (config.enableDeletingCommentWithReplies) {
            apex.server.plugin ( data.ajaxIdentifier, {
                        x01: 'D',
                        x02: commentJSON.id,
                        x03: commentJSON.parent,
                        x04: commentJSON.content,
                        x05: commentJSON.fullname,
                        x06: 'DELREPLIES'
                },  
                {
                        success: function( data )  {
                            isProcessSuccessfullyFinihed = data.success;
                        },
                        error: function( jqXHR, textStatus, errorThrown ) {
                            isProcessSuccessfullyFinihed = false;
                            apex.message.alert(jqXHR.responseJSON.message);
                }
            });
        }

        //Deleting comment
        if (!config.enableDeletingCommentWithReplies && isProcessSuccessfullyFinihed){
            apex.server.plugin ( data.ajaxIdentifier, {
                    x01: 'D',
                    x02: commentJSON.id,
                    x03: commentJSON.parent,
                    x04: commentJSON.content,
                    x05: commentJSON.fullname,
                    x06: 'DELCOMMENT'
            },  
            {
                success: function( data )  {
                    isProcessSuccessfullyFinihed = data.success;
                },
                error: function( jqXHR, textStatus, errorThrown ) {
                    isProcessSuccessfullyFinihed = false;
                    apex.message.alert(jqXHR.responseJSON.message);
                }
            });
        }

        //Updating parent IDs to null if enable deleting comment with replies disabled
        if (!config.enableDeletingCommentWithReplies && isProcessSuccessfullyFinihed) {
            apex.server.plugin ( data.ajaxIdentifier, {
                    x01: 'U',
                    x02: commentJSON.id,
                    x03: commentJSON.parent,
                    x04: commentJSON.content,
                    x05: commentJSON.fullname,
                    x06: 'UPDREPLIES'
            },  
            {
                success: function( data )  {
                    isProcessSuccessfullyFinihed = data.success;
                },
                error: function( jqXHR, textStatus, errorThrown ) {
                    apex.message.alert(jqXHR.responseJSON.message);
                }
            })
        }

        //manipulate DOM
        if (isProcessSuccessfullyFinihed) success(commentJSON);
    };

    //Update existing comment
    config.putComment = function(commentJSON, success, error) {

        //Update comment
        apex.server.plugin ( data.ajaxIdentifier, {
                x01: 'U',
                x02: commentJSON.id,
                x03: commentJSON.parent,
                x04: commentJSON.content,
                x05: commentJSON.fullname,
                x06: 'UPDCOMMENT',
                x07: commentJSON.profile_picture_url
        },  
        {
            success: function( data )  {
                success(commentJSON);
            },
            error: function( jqXHR, textStatus, errorThrown ) {
                apex.message.alert(jqXHR.responseJSON.message);
            }
        });

        //manipulate DOM
        success(commentJSON);
    };


    //Init config
    if (init && typeof init == 'function') init.call(this, config);

    //Init region
    apex.region.create(regionId, {
        type: 'apex-region-comments'
    });

    //initialize the commenting region
    $('#' + regionId).comments(config);

    //Fixing submit button issue : https://github.com/Viima/jquery-comments/issues/149
    $('#' + regionId).find('.action.edit').attr('type','button');
};


//creating pings for comments
COMMENTS.createPinginglistJSON = function(usersArray) {
    var list = {};

    usersArray.forEach(function(obj) { 
        list[obj.id] = obj.fullname;
    });

    return list;
}

//adding pings to comments
COMMENTS.addPingsJSON = function(usersArray,pings) {
    var pingsInString;

    usersArray.forEach(function(obj) {
        pingsInString = COMMENTS.getPingsInString(obj.content);
        obj.pings = COMMENTS.createPinginglistJSON(pings.filter(p => pingsInString.includes(p.id)));
    });
    
    return usersArray;
}

//get all pings in comment string
COMMENTS.getPingsInString = function(str) {
    const regex = /[^@\d]/g;
    return str.replaceAll(regex,'').split('@').map(Number);
}

//filter pinging list dynamically
COMMENTS.filterPingsList = function(list,name) {
    var n = new RegExp(name.toUpperCase());
    return list.filter(l => l.fullname.toUpperCase().match(n));
}