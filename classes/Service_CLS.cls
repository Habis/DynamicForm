/****************************************************************************************************
Desarrollado por:   VASS
Proyecto:           -
Descripción:        Interfaz a implementar por los callouts para centralizar su gestión

Cambios (Versiones)
-----------------------------------------------------------------------------------------------------
No.     Fecha           Autor                   Descripción
-----   ----------      --------------------    -----------------------------------------------------
1.0     2019-10-01		Jorge Levenfeld			Creación de la Clase.                                       
*/
public interface Service_CLS {

    void setRequestBody( RequestBody_CLS requestBody );
	void setRequestBody( String requestBody );
    void setAccessToken( String accessToken );
	void setUrlParams( Map<String, String> urlParams);
    ResponseBody_CLS run();
	ResponseBody_CLS setMockResponse();
	Object runNoDefinedObj();
	Object setMockResponseNoDefinedObj();
	String getMdtName();

	List<GetAllMovementsResponse> runBodyLst();
	List<GetAllMovementsResponse> setMockListResponse();
}