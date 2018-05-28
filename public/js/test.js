/**
 * Created by junjun on 2018/5/26.
 */

console.log("loaded...")

//var srt_url = `https://video.google.com/timedtext?hl=zh-TW&lang=zh-TW&v=kIzFz9T5rhI&fmt=vtt`
var srt_url = `https://video.google.com/timedtext??hl=en&lang=en&v=kIzFz9T5rhI&fmt=vtt`

function load_subtitle(url)
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
            window.vtt = tree;
        },
        complete:function(data)
        {
            console.log("complete",data);
        }

    });
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

setTimeout( function() {
    console.log("window loaded");
    load_subtitle(srt_url);

    if(interval != null)
    {
        clearInterval(interval);
    }

    interval = setInterval(function(){

            var v = document.getElementsByTagName("video")[0]
            var vtt = window.vtt;
            if( vtt && v )
            {
                var cur_time = v.getCurrentTime();


                for(let i = 0; i < vtt.cues.length; i++)
                {
                    if(cur_time > vtt.cues[i].endTime)
                        continue;
                    else
                    {
                        if(window.vtt_index != i)
                        {
                            console.log(cur_time);
                            window.vtt_index = i;
                            var cur_vtt = vtt.cues[i];
                            console.log(cur_vtt.text);

                            if(window.vvt_node)
                                window.vvt_node.remove();

                            var  pre_vtt_txt = "";
                            if(i-1 >= 0)
                            {
                                pre_vtt_txt = vtt.cues[i-1].text;
                            }

                            var  next_vtt_text = "";
                            if(i+1<vtt.cues.length)
                            {
                                next_vtt_text= vtt.cues[i+1].text;
                            }


                            window.vvt_node = jQuery(`<div id="vtt_node" style="width:100%;padding:4px;font-size:18px;z-index:1024;position:absolute; bottom:40px;background: black;color:white">
         
          <p style="text-align: center">${pre_vtt_txt}</p>
          <p style="text-align: center;font-size:18px;margin-top:10px;margin-bottom:10px;color:yellow">${cur_vtt.text}</p>
           <p style="text-align: center">${next_vtt_text}</p>
          
</div>`);

                            var append_position = null;
                            var selectors = ["#player-api"]
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

                            if(append_position != null)
                            {
                                append_position.append(function(index, html){
                                    if(index == 0)
                                    {
                                        return window.vvt_node;
                                        console.log("===")
                                    }
                                })

                                console.log("append_position is ",append_position[0]);
                                break;
                            }
                            else
                            {
                               console.log("append_position is null")
                            }



                        }
                        break;
                    }
                }
            }
    },500);
},3000);

