import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Nat  "mo:base/Nat";
import Bool "mo:base/Bool";
import Result "mo:base/Result";
import Text "mo:base/Text";

actor{
    type Time = Int;
    type Homework ={
        title:Text;
        description:Text;
        dueDate:Time;
        completed:Bool;
    };


var homeworkDairy = Buffer.Buffer<Homework>(10);
var homeworkDairyIndex : Nat = 0;



/*public shared func addHomework(homework:Homework): async Nat {
    homeworkDairy.add(homework);
    homeworkDairyIndex += 1;
    return homeworkDairyIndex-1;
};*/



public shared func addHomework(homework: Homework) : async Nat {
homeworkDairy.add(homework);

var id = getIndex(homework);
return id;
};

func getIndex(homework:Homework):Nat{
   switch (?Buffer.indexOf<Homework>(homework, homeworkDairy, compareHomework)) {
      case null { 0 };
      case (??id) { return id};
    };
};

 func compareHomework(h1:Homework,h2:Homework):Bool{
    if(h1==h2){
        return true;
    };
    return false;
};




public shared query func getHomework(id:Nat): async Result.Result<Homework,Text>{
    if(id >=  homeworkDairy.size()){
        return #err "Homework doesn't exist";
    };
  switch (?homeworkDairy.get(id)) {
  case null { #err "Homework doesn't exist"; };
  case (?homework) { #ok(homework); };
}
};

public shared query func getPendingHomework(): async [Homework]{
    var foundItems = Buffer.Buffer<Homework>(10);
    Buffer.iterate<Homework>(homeworkDairy, func (x) {
            if(x.completed==false){
                foundItems.add(x);
            }
    });
    return Buffer.toArray(foundItems);
};

public shared query func getAllHomework(): async [Homework]{
    return Buffer.toArray(homeworkDairy)
};

public shared func updateHomework(id:Nat,homework:Homework): async Result.Result<(),Text> {
        if(id >= homeworkDairy.size()){
        return #err "Homework doesn't exist";
        };
         switch (?homeworkDairy.put(id,homework)) {
        case null { #err "Homework doesn't exist"; };
        case (?homework) { return #ok(()) };
        }
};


public shared func deleteHomework(id:Nat): async Result.Result<(),Text> {
        if(id >= homeworkDairy.size()){
        return #err "Homework doesn't exist";
        };
         switch (?homeworkDairy.remove(id)) {
        case null { #err "Homework doesn't exist"; };
        case (?homework) { return #ok(()) };
        }
};

public shared query func searchHomework(searchTerm: Text): async [Homework] {
    var foundItems = Buffer.Buffer<Homework>(10);
    Buffer.iterate<Homework>(homeworkDairy, func (x) {
            if(Text.contains(x.title,#text searchTerm) or Text.contains(x.description,#text searchTerm)){
                foundItems.add(x);
            }
    });
    return Buffer.toArray(foundItems);
};



public shared func markAsCompleted(id:Nat): async Result.Result<(),Text> {
     if(id >= homeworkDairy.size()){
        return #err "Homework doesn't exist";
        };
          switch (?homeworkDairy.get(id)) {
            case null { #err "Homework doesn't exist"; };
            case (?homework) {
                let complete:Homework = {
                     title=homework.title;
                    description=homework.description;
                    dueDate=homework.dueDate;
                    completed=true;
                };
                homeworkDairy.put(id,complete);
                #ok();
                 };
}
};
};