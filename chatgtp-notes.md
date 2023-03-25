
如何让chatgpt保持会话：
https://ai.stackexchange.com/questions/38150/how-does-chatgpt-retain-the-context-of-previous-questions


这哥们的实现方式是用一种工具，把之前会话中的关键信息提取出来，然后做为prompt回传给chatgpt，我想这可能只对英语有效。 https://bitbucket.org/mfische/robot/src/main/robot.py

这个是通过 传递全部消息context的例子： https://medium.com/mlearning-ai/using-chatgpt-api-to-ask-contextual-questions-within-your-application-a80b6a76da98

了解什么是embedding    https://blinkdata.com/openai-embedding-tutorial/


  [关于ChatGPT的思考](http://fancyerii.github.io/2023/02/20/about-chatgpt/#llama) 这篇文章讲得比较详细，不过没时间完全看完。这里也需要数学的基础。
