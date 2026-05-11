Class dao.util
{

ClassMethod FromJSONFile(pFile As %String = "C:\InterSystems\openapi\upload_pdf_openapi_2_spec.json") As %DynamicAbstractObject
{
	Set tReturn = {}
	Try {
		Set tReturn = {}.%FromJSONFile(pFile)
	}
	Catch ex {
		//Do $System.Status.DisplayError(ex.AsStatus())
		// ERROR #5002: ObjectScript error: <METHOD DOES NOT EXIST>zFromJSONFile+3^dao.util.1 *%FromJSONFile,%Library.DynamicObject
		Try {
			//Set filename = "c:/iscsrc/json/greg4.json"
			Set stream = ##class(%Stream.FileCharacter).%New()
			Set sc = stream.LinkToFile(pFile)
			If ('sc) {
				Write "Error on linking file "_filename,!
				Quit
			}
			Try {
				Set tReturn = ##class(%DynamicAbstractObject).%FromJSON(stream)
			}
			Catch ex {
				Write "Error. Unable to parse file "_pFile,!
				Write "Error type   "_ex.Name,!
				Write "Error code   "_ex.Code,!
				Write "Error location "_ex.Location,!
				Set tReturn = ""
			}
		}
		Catch ex {
		}
	}
	Quit tReturn
}

}
