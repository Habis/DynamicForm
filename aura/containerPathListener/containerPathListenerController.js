({
    // Metodo que salta cada vez que se cambia el step
    handlePathChange : function(c, e, h){
		console.log("eeh sí? cuéntame más " , e.getParam("step"));
        var stepName = e.getParam("step");
		c.set("v.step", "");
		window.setTimeout(function(){
			c.set("v.step", stepName);

		},100)
    },
	cancelPath: function(c,e){
		console.log("event", e);
		let detail = e.getParams("detail");
		console.log("k pasa hermano", detail);
		if(detail.cancel){
			console.log("cancelamos",detail.actualStep);
			let pevt = $A.get("e.c:pathEventReset");
			pevt.setParams({"step": detail.actualStep});
			pevt.fire();

		}else if(detail.refresh){
			$A.get('e.force:refreshView').fire();
		}
	}
	
})
