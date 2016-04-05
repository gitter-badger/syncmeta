<script type="application/javascript">
    requirejs([
        'jqueryui',
        'lodash',
        'Util',
        'iwcw',
        'operations/non_ot/ExportMetaModelOperation',
        'operations/non_ot/ExportLogicalGuidanceRepresentationOperation',
        'canvas_widget/GenerateViewpointModel'
    ],function($,_,Util,IWCW,ExportMetaModelOperation,ExportLogicalGuidanceRepresentationOperation,GenerateViewpointModel){

        var componentName = "export"+Util.generateRandomId();

        var iwc = IWCW.getInstance(componentName);

        function generateSpace(spaceLabel,spaceTitle){

            function createSpace(spaceLabel,spaceTitle){
                var url = "<%= grunt.config('roleSandboxUrl') %>/spaces/" + spaceLabel;
                var deferred = $.Deferred();
                var innerDeferred = $.Deferred();

                //Delete space if already exists
                openapp.resource.get(url,function(data){
                    if(data.uri === url){
                        openapp.resource.del(url,function(){
                            innerDeferred.resolve();
                        });
                    } else {
                        innerDeferred.resolve();
                    }
                });

                //Create space
                innerDeferred.then(function(){
                    openapp.resource.post(
                            "<%= grunt.config('roleSandboxUrl') %>/spaces",
                            function(data){
                                deferred.resolve(data.uri);
                            },{
                                "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/role/terms/space",
                                "http://purl.org/dc/terms/title":spaceTitle,
                                "http://www.w3.org/2000/01/rdf-schema#label": spaceLabel
                            }
                    );
                });
                return deferred.promise();
            }

            function addWidgetToSpace(spaceURI,widgetURL){
                var deferred = $.Deferred();
                openapp.resource.post(
                        spaceURI,
                        function(data){
                            deferred.resolve(data.uri);
                        },{
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/role/terms/tool",
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type":"http://purl.org/role/terms/OpenSocialGadget",
                            "http://www.w3.org/2000/01/rdf-schema#seeAlso":widgetURL
                        }
                );
                return deferred.promise();
            }

            function addMetamodelToSpace(spaceURI,metamodel, type){
                var deferred = $.Deferred();
                var deferred2 = $.Deferred();
                openapp.resource.post(
                        spaceURI,
                        function(data){
                            deferred.resolve(data.uri);
                        },{
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/role/terms/data",
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type":type
                        });
                deferred.promise().then(function(dataURI){
                    openapp.resource.put(
                            dataURI,
                            function(){
                                deferred2.resolve();
                            },{
                                "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/openapp/representation"
                            },JSON.stringify(metamodel));
                });
                return deferred2.promise();
            }


            function addGuidanceRulesToSpace(spaceURI, guidanceRules){
                var deferred = $.Deferred();
                var deferred2 = $.Deferred();
                openapp.resource.post(
                        spaceURI,
                        function(data){
                            deferred.resolve(data.uri);
                        },{
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/role/terms/data",
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type":"my:ns:guidancerules"
                        });
                deferred.promise().then(function(dataURI){
                    openapp.resource.put(
                            dataURI,
                            function(){
                                deferred2.resolve();
                            },{
                                "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/openapp/representation"
                            },JSON.stringify(guidanceRules));
                });
                return deferred2.promise();
            }

            function addLogicalGuidanceRepresentationToSpace(spaceURI, logicalGuidanceRepresentation){
                var deferred = $.Deferred();
                var deferred2 = $.Deferred();
                openapp.resource.post(
                        spaceURI,
                        function(data){
                            deferred.resolve(data.uri);
                        },{
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/role/terms/data",
                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type":CONFIG.NS.MY.LOGICALGUIDANCEREPRESENTATION
                        });
                deferred.promise().then(function(dataURI){
                    openapp.resource.put(
                            dataURI,
                            function(){
                                deferred2.resolve();
                            },{
                                "http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate":"http://purl.org/openapp/representation"
                            },JSON.stringify(logicalGuidanceRepresentation));
                });
                return deferred2.promise();
            }

            function storeGeneratedInstanceMeta(spaceURI,spaceTitle){
                var resourceSpace = new openapp.oo.Resource(openapp.param.space()),
                        deferred = $.Deferred(),
                        outerDeferred = $.Deferred(),
                        promises = [],
                        data = {
                            url: spaceURI,
                            title: spaceTitle
                        };

                resourceSpace.getSubResources({
                    relation: openapp.ns.role + "data",
                    type: CONFIG.NS.MY.INSTANCE,
                    onAll: function(data) {
                        if(data !== null && data.length !== 0){
                            _.map(data,function(d){
                                var deferred = $.Deferred();
                                d.getRepresentation("rdfjson",function(representation){
                                    if(representation && representation.url && representation.url === spaceURI){
                                        d.del();
                                    }
                                    deferred.resolve();
                                });
                                Util.delay(1000).then(function(){
                                    deferred.resolve();
                                });
                                promises.push(deferred.promise());
                            });
                        }
                        outerDeferred.resolve();
                    }
                });
                outerDeferred.then(function(){
                    $.when.apply($,promises).then(function(){
                        resourceSpace.create({
                            relation: openapp.ns.role + "data",
                            type: CONFIG.NS.MY.INSTANCE,
                            representation: data,
                            callback: function(){
                                deferred.resolve();
                            }
                        });
                    });
                });
                return deferred.promise();
            }

            function getMetaModel(){
                var deferred = $.Deferred();
                Util.GetCurrentBaseModel().done(function(meta){
                    deferred.resolve(GenerateViewpointModel(meta));
                });
                return deferred.promise();
            }

			function getViewpoints(){
				var deferred = $.Deferred();
				 var resourceSpace = new openapp.oo.Resource(openapp.param.space());
				 resourceSpace.getSubResources({
						relation: openapp.ns.role + "data", type: CONFIG.NS.MY.VIEW,
						onAll: function(viewpoints) {
							deferred.resolve(viewpoints); 
						} 
					}); 
				return deferred.promise();
			}
			function GetViewPoint(resource){
				var deferred = $.Deferred();
				resource.getRepresentation("rdfjson",function(rep){
					deferred.resolve(rep); 
				});
				return deferred.promise();
			}

            return $.when(getMetaModel(), getViewpoints(),getLogicalGuidanceRepresentation())
                .then(function(metamodel, viewpoints,logicalGuidanceRepresentation){
                return createSpace(spaceLabel,spaceTitle)
                    .then(function(spaceURI){
                         return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/activity.xml")
                             .then(function(){
                                  return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/widget.xml");
                             }).then(function(){
                      return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/palette.xml");
                             }).then(function(){
                      return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/attribute.xml");
                            }).then(function(){
                      return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/debug.xml");
                      }).then(function(){
                         return addMetamodelToSpace(spaceURI,metamodel, CONFIG.NS.MY.METAMODEL);
                      }).then(function(){
                       var deferred = $.Deferred();
                            for(var i=0;i<viewpoints.length;i++){
                                GetViewPoint(viewpoints[i]).then(function(viewpoint){
                                var viewpointmodel = GenerateViewpointModel(viewpoint);
                                addMetamodelToSpace(spaceURI, viewpointmodel, CONFIG.NS.MY.VIEWPOINT);
                                });
                            }
                        deferred.resolve();
                        return deferred.promise();
                       })
                       .then(function(){
                            return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/guidance.xml");
                       }).then(function(){
                            return addWidgetToSpace(spaceURI,"<%= grunt.config('baseUrl') %>/heatmap.xml");
                       }).then(function(){
                            return addLogicalGuidanceRepresentationToSpace(spaceURI, logicalGuidanceRepresentation);
                        }).then(function(){
                               return {
                                  spaceURI: spaceURI,
                                  spaceTitle: spaceTitle
                                };
                       });


                    })
                   });

            function getLogicalGuidanceRepresentation(){
                var deferred = $.Deferred();
                iwc.registerOnDataReceivedCallback(function(operation){
                    if(operation instanceof ExportLogicalGuidanceRepresentationOperation){
                        deferred.resolve(operation.getData());
                    }
                });
                var operation = new ExportLogicalGuidanceRepresentationOperation(componentName,null);
                iwc.sendLocalNonOTOperation(CONFIG.WIDGET.NAME.MAIN,operation.toNonOTOperation());
                return deferred.promise();
            }

        }

        $(function(){
            var $list = $("#list"),
                templateString = '<li><a href="<<= url >>" target="_blank"><<= title >></a></li>'.replace(/<</g,"<"+"%").replace(/>>/g,"%"+">"),
                template = _.template(templateString),
                resourceSpace = new openapp.oo.Resource(openapp.param.space());

            function getInstances(){
                var promises = [],
                    outerDeferred = $.Deferred(),
                    list = [];

                $list.empty();

                resourceSpace.getSubResources({
                    relation: openapp.ns.role + "data",
                    type: CONFIG.NS.MY.INSTANCE,
                    onAll: function(data) {
                        if(data !== null && data.length !== 0){
                            _.map(data,function(d){
                                var deferred = $.Deferred();
                                d.getRepresentation("rdfjson",function(representation){
                                    if(!representation){
                                        deferred.resolve();
                                    } else {
                                        list.push(representation);
                                        deferred.resolve();
                                    }
                                });
                                Util.delay(1000).then(function(){
                                    deferred.resolve();
                                });
                                promises.push(deferred.promise());
                            });
                        }
                        outerDeferred.resolve();
                    }
                });
                outerDeferred.then(function(){
                    $.when.apply($,promises).then(function(){
                        _.map(_.sortBy(list,function(e){return e.title.toLowerCase();}),function(e){
                            $list.append(template({url: e.url, title: e.title}));
                        })
                    });
                });
            }

            getInstances();

            var timeout;

            $("#space_label").change(function(){
                var $this = $(this);

                clearTimeout(timeout);
                timeout = setTimeout(function(){
                    $this.addClass('loading_button');
                    var url = "<%= grunt.config('roleSandboxUrl') %>/spaces/" + $this.val().replace(/[^a-zA-Z]/g,"").toLowerCase();
                    openapp.resource.get(url,function(data){
                        if(data.uri === url){ //Space already exists
                            if(data.data[data.subject['http://purl.org/openapp/owner'][0].value]['http://www.w3.org/2002/07/owl#sameAs'][0].value === openapp.param.user()){
                                $("#space_link_comment").show();
                                $("#space_link_comment_no_access").hide();
                                $("#submit").prop('disabled',false);
                                $this.css({border: "1px solid #FF3333"});
                            } else {
                                $("#space_link_comment").hide();
                                $("#space_link_comment_no_access").show();
                                $("#submit").prop('disabled',true);
                                $this.css({border: "1px solid #FF3333"});
                            }
                        } else {
                            $("#space_link_comment_no_access").hide();
                            $("#space_link_comment").hide();
                            $("#submit").prop('disabled',false);
                            $this.css({border: ""});
                        }
                        $this.removeClass('loading_button');
                    });

                },200);
            }).change();

            $("#submit").click(function(){
                $(this).addClass('loading_button');
                var title = $("#space_title").val();
                var label = $("#space_label").val().replace(/[^a-zA-Z]/g,"").toLowerCase();

                if(title === "" || label === "") return;
                generateSpace(label,title).then(function(spaceObj){
                    var operation = new ExportMetaModelOperation(componentName,spaceObj);
                    iwc.sendLocalNonOTOperation(CONFIG.WIDGET.NAME.MAIN,operation.toNonOTOperation());

                    $("#space_link").text(spaceObj.spaceURI).attr('href', spaceObj.spaceURI).show();
                    $("#space_link_text").show();
                    $("#space_link_input").hide();
                    $("#submit").removeClass('loading_button').hide();
                    $("#reset").show();
                });
            });

            $("#reset").click(function(){
                $("#space_link").text('').attr('href','').hide();
                $("#space_link_text").hide();
                $("#space_link_input").show();
                $("#submit").show();
                $("#reset").hide();
            }).hide();

        });
    });
</script>
<style>
    #list {
        list-style: none;
        padding: 0;
        margin: 0;
        overflow-y: scroll;
        height: 100%;
    }
    a, a:visited, a:hover, a:focus {
        color: #333333;
        white-space: nowrap;
    }
    p {
        margin: 8px 0;
    }

    /*noinspection CssUnusedSymbol*/
    .loading_button {
        /*noinspection CssUnknownTarget*/
        background-image: url('<%= grunt.config('baseUrl') %>/img/loading_small.gif');
        background-repeat: no-repeat;
        background-position: right center;
        padding-right: 20px;
    }
</style>
<p><strong>Editor space url:</strong>
    <br/>
    <span id="space_link_input"><%= grunt.config('roleSandboxUrl') %>/<input size="16" type="text" id="space_label" /></span>
    <span id="space_link_text" style="display: none"><a id="space_link" target="_blank" href="#"></a></span>
    <br/>
    <span id="space_link_comment" style="color: #FF3333; display: none">Space already exists, will be overwritten!</span>
    <span id="space_link_comment_no_access" style="color: #FF3333; display: none">Space already exists, cannot be overwritten!</span>
</p>
<p><strong>Editor space title:</strong>
<br/>
<input size="32" type="text" id="space_title" /></p>
<button id="submit">Generate</button>
<button id="reset">Reset</button>
<p><strong>Generated instances:</strong>
<ul id="list"></ul>