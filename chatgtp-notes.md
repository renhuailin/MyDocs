
如何让chatgpt保持会话：
https://ai.stackexchange.com/questions/38150/how-does-chatgpt-retain-the-context-of-previous-questions


这哥们的实现方式是用一种工具，把之前会话中的关键信息提取出来，然后做为prompt回传给chatgpt，我想这可能只对英语有效。 https://bitbucket.org/mfische/robot/src/main/robot.py

这个是通过 传递全部消息context的例子： https://medium.com/mlearning-ai/using-chatgpt-api-to-ask-contextual-questions-within-your-application-a80b6a76da98
