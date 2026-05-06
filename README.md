# iris-rest
```
echo "# iris-rest" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/oliverwilms/iris-rest.git
git push -u origin main
```

https://docs.intersystems.com/iris20261/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_mgmnt#GREST_mgmnt_class_create

Obtain the OpenAPI 2.0 specification for the REST service, in JSON format, and save the specification as a file. The file must be UTF-8 encoded.

In the namespace where you want to define the REST service, use the file to create an instance of %DynamicObject.

Then call the CreateApplication() method of the %REST.API class.
