/**
 * Created by junjun on 2018/5/26.
 */

const FlagEn = "en";
const FlagTran = 'tran';

console.log("loaded...")
window
//var srt_url_tran = `https://video.google.com/timedtext?hl=zh-TW&lang=zh-TW&v=kIzFz9T5rhI&fmt=vtt`

function load_subtitle(url,flag)
{
    console.log("load_subtitle:",url)
    jQuery.ajax({
        type: "GET",
        url: url,
        // dataType: "html/text",
        success: function(data){
            //console.log("success",data);

            var parser = new WebVTTParser();
            var tree = parser.parse(data);
            console.log("tree",tree);
            if(flag == FlagEn)
            {
                window.vtt = tree;
            }
            else if(flag == FlagTran)
            {
                window.vtt_tran = tree;
            }
        },
        complete:function(data)
        {
            console.log("complete",data);
        }

    });
}

window.add_subtitle=function(v,cur_vtt,cur_vtt_tran,pre_time,next_time)
{

    var nodes = jQuery(`<div id="vtt_node" style="width:100%;padding:2px;margin-top:-16px;font-size:18px;position:relative;background: black;color:white;display:inline-block"></div>`);

    if(pre_time!=null && pre_time>=0)
    {
        console.log("add pre_time");
        var node_pre = jQuery(`<div id="pre_btn" style="color:white;width:10%;display:inline-block;vertical-align: middle"><<pre></div>`);
        node_pre.on("click", function(){
            if(v)
            {
                console.log("set currentTime:",pre_time);
                v.currentTime = pre_time;
            }
        });

        nodes.append(node_pre);
    }

    var subtitles = jQuery(`<div id="subtitle_container" style="width:80%;display:inline-block;vertical-align: middle"></div>`)
    if(cur_vtt)
    {
        var tmp = jQuery(`<p id="cur_vvt" style="text-align: center;font-size:18px;margin-top:10px;margin-bottom:10px;color:yellow">${cur_vtt.text}</p>`);
        subtitles.append(tmp);
    }

    if(cur_vtt_tran)
    {
        var tmp = jQuery(`<p id="cur_vvt_tran" style="text-align: center;font-size:18px;margin-top:10px;margin-bottom:10px;color:yellow">${cur_vtt_tran.text}</p>`);
        subtitles.append(tmp);
    }

    nodes.append(subtitles);


    if(next_time!=null && next_time>=0)
    {
        console.log("add next_time");
        var node_pre = jQuery(`<div id="next_btn" style="color:white;width:10%;display:inline-block;vertical-align: middle">></div>`);
        node_pre.on("click", function(){
            if(v)
            {
                console.log("set currentTime:",next_time);
                v.currentTime = next_time;
            }
        });

        nodes.append(node_pre);
    }



    if(window.vvt_node)
    {
        window.vvt_node.remove();
    }

    window.vvt_node = nodes;
    //
    // window.vvt_node.on("click",function(){
    //     console.log("cur_vvt",$(this).text());
    //     troggle(v); })

    var append_position = null;
    var selectors = ["#watch-headline-title","#container","#container > h1.title.style-scope.ytd-video-primary-info-renderer"]
    for(let i = 0; i < selectors.length; i++)
    {
        append_position = jQuery(selectors[i]);
        if(append_position && append_position.length > 0 )
        {
            break;
        }
        else
        {
            append_position = null;
        }
    }

    //alert(append_position);

    if(append_position != null)
    {
        window.vvt_node.insertAfter(append_position);

        console.log("append_position is ",append_position[0]);
    }
    else
    {
        console.log("append_position is null")
    }
}

function get_params_map()
{
    var ret = {};
    var params_str = window.location.search.substring(1);
    if(params_str)
    {
        var param_strs = params_str.split("&");
        for(var i = 0; i < param_strs.length; i++)
        {
            var param_= param_strs[i];
            var pair =  param_.split("=");
            if(pair && pair.length == 2)
            {
                ret[pair[0]] = pair[1];
            }

        }
    }
    return ret;
}

function get_params(name)
{
    var ret = get_params_map();
    return  ret[name];
}

var jquery_url = "https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"
var vtt_url = 'https://quuz.org/webvtt/parser.js'

var urls = [jquery_url,vtt_url]
for(var i = 0; i < urls.length; i++)
{
    let script = document.createElement('script');
    script.src = urls[i];
    document.getElementsByTagName('head')[0].appendChild(script);

}

var interval = null;

function troggle(v)
{
    if(!v)
        return;

    if(v.paused == null || v.paused == undefined)
        return;

    if(v.paused == true)
    {
        v.play();
    }
    else
    {
        v.pause()
    }
}

setTimeout( function() {
    console.log("window loaded");

    var v_id = get_params("v");
    if(!v_id)
    {
        alert("没有获取到视频id");
        return;
    }

    var srt_url_tran = `https://video.google.com/timedtext?hl=zh-CN&lang=zh-CN&v=${v_id}&fmt=vtt`
    var srt_url = `https://video.google.com/timedtext??hl=en&lang=en&v=${v_id}&fmt=vtt`


    //alert(v_id);
    load_subtitle(srt_url,FlagEn);
    load_subtitle(srt_url_tran,FlagTran)

    if(interval != null)
    {
        clearInterval(interval);
    }

    interval = setInterval(function(){

            var v = document.getElementsByTagName("video")[0]
            var vtt = window.vtt;
            var vtt_tran = window.vtt_tran

            if( (vtt || vtt_tran) && v )
            {
                var cur_time = v.getCurrentTime();
                var changed = false;
                if(vtt)
                {
                    for (let i = 0; i < vtt.cues.length; i++) {
                        if (cur_time > vtt.cues[i].endTime)
                        {
                            continue;
                        }
                        else
                        {
                            if (window.vtt_index != i)
                            {
                                window.vtt_index = i;
                                changed = true;
                            }
                            break;
                        }
                    }
                }//if(vtt) end

                if(vtt_tran)
                {
                    for (let i = 0; i < vtt_tran.cues.length; i++) {
                        if (cur_time > vtt.cues[i].endTime)
                        {
                            continue;
                        }
                        else
                        {
                            if (window.vtt_tran_index != i)
                            {
                                window.vtt_tran_index = i;
                                changed = true;
                            }
                            break;
                        }
                    }
                }//if(vtt_tran) end


                if(changed == true)
                {
                    var en_cur_vtt = null;
                    var pre_time = null;
                    var next_time = null;

                    if(window.vtt_index && window.vtt_index >= 0)
                    {
                        en_cur_vtt = window.vtt.cues[window.vtt_index];
                        console.log(`en: ${en_cur_vtt.startTime} : ${en_cur_vtt.text}`)

                        if( window.vtt_index > 1)
                        {
                            pre_time = window.vtt.cues[window.vtt_index-1].startTime;
                        }

                        if( window.vtt_index < window.vtt.cues.length-1)
                        {
                            next_time = window.vtt.cues[window.vtt_index+1].startTime;
                        }

                    }

                    var en_cur_vtt_tran = null;
                    if(window.vtt_tran_index && window.vtt_tran_index >= 0)
                    {
                        en_cur_vtt_tran = window.vtt_tran.cues[window.vtt_tran_index];
                        console.log(`tran: ${en_cur_vtt_tran.startTime} : ${en_cur_vtt_tran.text}`)
                    }

                    window.add_subtitle(v,en_cur_vtt,en_cur_vtt_tran,pre_time,next_time);

                }

            }// if( (vtt || vtt_tran) && v ) end



    },500);

},3000);


