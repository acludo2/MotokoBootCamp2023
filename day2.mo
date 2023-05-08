import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Nat  "mo:base/Nat";
import Bool "mo:base/Bool";
import Result "mo:base/Result";

actor{
    type Time = Int;
    type Homework ={
        title:Text;
        description:Text;
        dueDate:Time;
        complete:Bool;
    };


var homeworkDairy = Buffer.Buffer<Homework>(10);
var homeworkDairyIndex : Nat = 0;



public shared func addHomework(homework:Homework): async Nat {
    homeworkDairy.add(homework);
    homeworkDairyIndex += 1;
    return homeworkDairyIndex-1;
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
                    complete=true;
                };
                homeworkDairy.put(id,complete);
                #ok();
                 };
}

};


};