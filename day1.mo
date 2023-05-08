import Float "mo:base/Float";



actor {
    /*(add : shared(x : Float) -> async Float;
    sub : shared(x : Float) -> async Float;
    mul : shared(x : Float) -> async Float;
    div : shared(x : Float) -> async Float;
    reset: shared () -> async ();
    see: shared query () -> async Float;
    power: shared (x : Float) -> async Float;
    sqrt: shared () -> async Float;
    floor: shared () -> async Int;
*/

    var counter : Float = 0;


    public shared func add(x : Float): async Float {
        counter += x;
        return counter;
    };


    public shared func sub(x:Float): async Float {
        counter -= x;
        return counter;
    };


    public shared func mul(x:Float): async Float {
        counter *=x;
        return counter;
    };

    public shared func div(x:Float): async Float {
        if(x==0){
            return 0;
        };
        counter /=x;
        return counter;
    };



    public shared func reset(): async () {
          counter := 0;
    };


    public shared query func see() : async Float {
            return counter;
    };

    public shared func power(x:Float): async Float {
        counter := counter**x;
        return counter;
    };

    public shared func sqr():async Float {
        counter := Float.sqrt(counter);
        return counter;
    };

    public shared func floor():async Int {
        counter := Float.nearest(counter);
        var floorInt:Int = Float.toInt(counter);
        return floorInt;
    };
};