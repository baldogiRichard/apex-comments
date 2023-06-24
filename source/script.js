/* globals apex,$ */
window.COMMENTS = window.COMMENTS || {};

//Initialize plugin
COMMENTS.initialize = function(config, vData, init) {

    //parse data
    var data = JSON.parse(vData);

    //regionid and convert pinginglist to acceptable JSON format for the API
    var regionId = data.regionId;
    var commentsWithPings = COMMENTS.addPingsJSON(data.comments,data.pingingList);

    //filter item value
    var filterVal = apex.item(data.filterItemName).getValue();

    //sort comments
    data.comments = COMMENTS.sortComments(data.comments);

    //set hasChild attribute
    data.comments = COMMENTS.hasChildren(data.comments);

    //set parentIsRoot attribute
    data.comments = COMMENTS.parentIsRoot(data.comments);

    //set childIsFirst attribute
    data.comments = COMMENTS.childIsFirstCheck(data.comments);

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
                x05: apex.item(data.userNameItem).getValue(),
                x06: 'INSCOMMENT',
                x07: apex.item(data.ProfilePicsItem).getValue(),
                x08: filterVal
        },
        {
            success: function( data )  {
                success(commentJSON);
                $("[data-id=" + commentJSON.id + "]").attr("data-id",data.success);
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
                        x06: 'DELREPLIES',
                        x07: commentJSON.profile_picture_url,
                        x08: filterVal
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
                    x06: 'DELCOMMENT',
                    x07: commentJSON.profile_picture_url,
                    x08: filterVal
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
                    x06: 'UPDREPLIES',
                    x07: commentJSON.profile_picture_url,
                    x08: filterVal
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
                x05: apex.item(data.userNameItem).getValue(),
                x06: 'UPDCOMMENT',
                x07: apex.item(data.ProfilePicsItem).getValue(),
                x08: filterVal
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
    COMMENTS.createCommentRegion(config,regionId,data.ajaxIdentifier);

    //initialize the commenting region
    $('#' + regionId).comments(config);
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

//check if comment have children
COMMENTS.hasChildren = function (comments) {    
    var newComments = comments;
    //comments id
    for (let i = 0; i < newComments.length; i++) {
        newComments[i].hasChild = false;
        //check for same id in parent
        for (let k = 0; k < comments.length; k++) {
            if (comments[k]["parent"] === newComments[i].id) {
                newComments[i].hasChild = true;
                break;
            }
        }
    }
    //return updated version
    return newComments;
}

//check if parent ID is root ID
COMMENTS.parentIsRoot = function (comments) {
    var rootParents = [];    
    //get root parents
    for (let i = 0; i < comments.length; i++) {
        //check if comment is root parent
        if(typeof(comments[i].parent) === "undefined") {
            rootParents.push(comments[i].id);
        }
    }
    //check if parent is contained in array
    for (let i = 0; i < comments.length; i++) {
        comments[i].parentIsRoot = rootParents.includes(comments[i].parent);
    }
    //return updated version
    return comments;
}

//convert id to number. slice 'c' from string and convert the rest to number
COMMENTS.convertIdIntoNumber = function(id) {
    return parseInt(id.slice(1));  
}

//check if the current id is the first child of the parent when childs are existing
COMMENTS.childIsFirstCheck = function (comments) {
    var extendedComments = comments;
    
    //comments id
    for (let i = 0; i < extendedComments.length; i++) {
        extendedComments[i].childIsFirst = false;
        //check if id in parent is first child
        for (let k = 0; k < comments.length; k++) {
            if (comments[k].parent) {
                if (comments[k].parent === extendedComments[i].parent) {
                    if (comments[k].id != extendedComments[i].id) {
                        extendedComments[i].childIsFirst = (COMMENTS.convertIdIntoNumber(extendedComments[i].id) < COMMENTS.convertIdIntoNumber(comments[k].id));                       
                    }
                }
            }
        }
    }

    //return updated version
    return extendedComments;
}

//order json
COMMENTS.sortComments = function (comments) {
    comments.sort(function(a, b){
        return COMMENTS.convertIdIntoNumber(a.id) - COMMENTS.convertIdIntoNumber(b.id);
    });
    return comments;
}

//create region
COMMENTS.createCommentRegion = function (pConfig,pCommentRegionId,ajaxIdentifier) {
    apex.region.create( pCommentRegionId, {
        type: "apex-region-comments",
        refresh: function() {
            apex.server.plugin ( ajaxIdentifier, {
                    x01: 'R'
            },
            {
                success: function( data )  {
                    var vDataComments = JSON.parse(data.comments);

                    pConfig.getComments = function(success, error) {
                        success(vDataComments);
                    };

                },
                error: function( jqXHR, textStatus, errorThrown ) {
                    apex.message.alert(jqXHR.responseJSON.message);
                }
            })
        }
    } );
}
