({
    handleSelectStep : function(cmp, evt, helper){
        
        let stepName = evt.getParam("detail").value;
        console.log(stepName);
        let pevt = $A.get("e.c:pathEvent");
		pevt.setParams({"step": stepName});
        pevt.fire();

    },
	handleResetPath : function(c,e,h){
		let recId = c.get("v.recordId");
		c.set("v.recordId", null);
		window.setTimeout(function(){
		c.set("v.recordId", recId);
			console.log('ahora quñe', c.get("v.recordId"));
		}, 1000);

		$A.get('e.force:refreshView').fire();
		
		

	}
})