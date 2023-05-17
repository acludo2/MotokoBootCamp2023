import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";


actor{
    public type MessageId = Nat;
    public type Content = {
        #Text:Text;
        #Image:Blob;
        #Video:Blob;
    };
    public type Message = {
        vote:Int;
        content:Content;
        creator:Principal;
    };

    var messageId:MessageId = 0;



    var wall = HashMap.HashMap<Text,Message>(1,Text.equal,Text.hash);


    public shared(msg) func writeMessage(c:Content):async Nat {
        let newMessage: Message = {
            vote=0;
            content=c;
            creator=msg.caller;
        };
        wall.put(Nat.toText(messageId),newMessage);
        messageId +=1;
        return messageId-1;
    };

    public shared query func getMessage(messageid:Nat):async Result.Result<Message,Text> {
        switch (wall.get(Nat.toText(messageid))) {
            case null { #err "Message doesnt exist"; };
            case (?message) { #ok(message); };
            }
    };


     public shared(msg) func updateMessage(messageid:Nat,c:Content):async Result.Result<(),Text> {

        var result = await getMessage(messageid);
        if(Result.isOk(result)){
            var message = Result.toOption(result);

            return#ok()
        }else{
            return #err "error";
        };

        /*switch (wall.get(Nat.toText(messageid))) {
            case null { #err "Message doesnt exist"; };
            case (?messageFound) {
                if(msg.caller==messageFound.creator){
                    let newMessage:Message ={
                    vote=messageFound.vote;
                    content=c;
                    creator=messageFound.creator;
                     };
                     ignore wall.replace(Nat.toText(messageid),newMessage);
                return #ok(());
                };
                #err "Message doesnt exist";
                };
            }*/
    };

    public  shared(msg) func deleteMessage(messageid:Nat):async Result.Result<(),Text> {
             if(messageid >= wall.size()){
                  return #err "Message doesn't exist";
                    };
        switch (wall.get(Nat.toText(messageid))) {
            case null { #err "Message doesnt exist"; };
            case (?messageFound) {
                if(msg.caller==messageFound.creator){
                     ignore wall.remove(Nat.toText(messageid));
                return #ok(());
                };
                #err "Message doesnt exist";
                };
            }
    };


    public query func getAllMessages(): async[Message]{
        var allMessages = Buffer.Buffer<Message>(10);
            for (value in wall.vals()) {
                  allMessages.add(value);
        };
        return Buffer.toArray(allMessages);
    };

     public query func getAllMessagesRanked(): async[Message]{
        var allMessages = Buffer.Buffer<Message>(10);
        var index:Nat = 0;
        var jndex:Nat = 0;
            for (value in wall.vals()) {
                  allMessages.add(value);
        };

        for (v1 in allMessages.vals()) {
                jndex :=0;
                for (v2 in allMessages.vals()){
                    var temp1 = allMessages.get(index);
                    var temp2 = allMessages.get(jndex);
                     if(temp1.vote > temp2.vote){
                        allMessages.put(index,temp2);
                        allMessages.put(jndex,temp1);
                    };
                        jndex +=1;
            };
                     index +=1;
            };
        return Buffer.toArray(allMessages);
    };


     public shared(msg) func upVote(messageid:Nat,):async Result.Result<(),Text> {
                 if(messageid >= wall.size()){
                  return #err "Message doesn't exist";
                    };
        switch (wall.get(Nat.toText(messageid))) {
            case null { #err "Message doesnt exist"; };
            case (?messageFound) {
                      var newVote:Int = messageFound.vote;
                      newVote +=1;
                    let newMessage:Message ={
                    vote=newVote;
                    content=messageFound.content;
                    creator=messageFound.creator;
                     };
                     ignore wall.replace(Nat.toText(messageid),newMessage);
                return #ok(());

                };
            }
    };


      public shared(msg) func downVote(messageid:Nat):async Result.Result<(),Text> {
                 if(messageid >= wall.size()){
                  return #err "Message doesn't exist";
                    };
        switch (wall.get(Nat.toText(messageid))) {
            case null { #err "Message doesnt exist"; };
            case (?messageFound) {
                      var newVote:Int = messageFound.vote;
                      newVote -=1;
                    let newMessage:Message ={
                    vote=newVote;
                    content=messageFound.content;
                    creator=messageFound.creator;
                     };
                     ignore wall.replace(Nat.toText(messageid),newMessage);
                return #ok(());

                };
            }
    };









};

