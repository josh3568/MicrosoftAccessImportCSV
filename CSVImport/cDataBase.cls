VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "cDataBase"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private poDatabase As Database
Private poCurrentData As CurrentData
Private pvTables() As Variant 'of cTables

Public Sub InitializecDatabase()
'Loads in all the data into the object
    Set poDatabase = Application.CurrentDb
    Set poCurrentData = Application.CurrentData
    SetcTables
    CheckRelated
End Sub

Public Property Get vTables() As Variant
'returns pvtables
    vTables = pvTables
End Property

Public Property Get oDataTables() As Variant
'returns pvtables
    Set oDataTables = poDataTables
End Property

Public Property Get oDatabase() As Database
'Loads in all the data into the object
    Set oDatabase = poDatabase
End Property

Public Property Get oCurrentData() As CurrentData
'Loads in all the data into the object
    Set oCurrentData = poCurrentData
End Property

Sub Main()
'imports a CSV file and goes through all cells to import into the poDataBase
  Dim FilePath As String
    
    'Read CSV file
    FilePath = xxx
    
    Open FilePath For Input As #1
    
    i = 0
    j = 0
    
    'go through all rows
    Do Until EOF(1)
        Line Input #1, LineFromFile
        PathLineItems = Split(LineFromFile, ",")
        
        'go through all columns
        For j = 0 To UBound(PathLineItems)
            'get headers
            If i = 0 Then
                Headers = PathLineItems
                Exit For
            Else
            
            'get data
            If j <= UBound(Headers) Then
                ActiveColumn = Headers(j)
            Else
                ActiveColumn = ""
            End If
            
            sTable = DetermineTableName(ActiveColumn)
            ActiveCell = PathLineItems(j)
            CellDataType = DetermineDataType(ActiveCell)
            End If
        Next j
    Loop
    
    Close #1

End Sub

Function DetermineTableName(sFieldName As String) As String
'Determines the TableName based on the Fieldname

End Function

Function DetermineDataType(sFieldName As String) As Integer
'Determines the datatype of the string

End Function

Sub SetcTables()
'Loads in all the tablenames into the object

    Dim Tables As Variant
    Dim tbl As TableDef
    Dim NumTables As Integer
    Dim vTemp As Variant
    Dim i As Integer
    Dim j As Integer
    Dim CurrentcTable As cTable
     
    i = -1
    
    'Error handling
    If IsEmpty(poDatabase) Then Exit Sub
    
    'Put the tables into the array
    For Each tbl In poDatabase.TableDefs
        i = i + 1
        Set tbl = poDatabase.TableDefs(i)
        
        'Filter out hidden tables
        If Not Left(tbl.Name, 4) = "Msys" Then
            If IsEmpty(vTemp) Then
                'create a new list
                Set CurrentcTable = NewcTable(tbl)
                Set CurrentcTable.Database = poDatabase
                vTemp = Array(CurrentcTable)
            Else
                'append to the list
                ReDim Preserve vTemp(0 To UBound(vTemp) + 1)
                Set CurrentcTable = NewcTable(tbl)
                Set CurrentcTable.Database = poDatabase
                Set vTemp(UBound(vTemp)) = CurrentcTable
            End If
        End If
    Next tbl
    pvTables = vTemp
End Sub

Sub CheckRelated()
'Goes through two tables and links any tables with matching fields
'names and datatypes
    Dim Rel As Relations
    Dim i As Integer
    Dim oFields As Fields
    Dim sName As String
    Dim vRelatesTo As Variant 'of cFields
    Dim j As Integer
    Dim k As Integer
    Dim CurrentTable As cTable
    Dim oRelation As Relation
    Dim oHeader As Field2
    Dim sTableName As String
    Dim sForeignTable As String
    Dim OTemp1 As cTable
    Dim OTemp2 As cTable
    Dim n As Integer
    Dim m As Integer
    Dim bReadOnly1 As Boolean
    Dim bReadOnly2 As Boolean
    Dim oTemp1Index As Integer
    Dim oTemp2Index As Integer
    Dim oTemp1List As Variant
    Dim oTemp2List As Variant
    Dim sFieldName As String
    Dim sFieldForeignName As String
    Dim oField1 As cField
    Dim oField2 As cField
    Dim sFieldsCount As Integer
    Dim Temp As Fields
    Dim x As Integer
    Dim CurrentField1 As cField
    Dim CurrentField2 As cField
    Dim OTemp1FieldIndex As Integer
    Dim OTemp2FieldIndex As Integer
    Dim oTemp1FieldList As Variant
    Dim oTemp2FieldList As Variant
    
    'Error handling
    If IsEmpty(poDatabase) Then Exit Sub
    If IsEmpty(pvTables) Then Exit Sub
    
    Set Rel = poDatabase.Relations

    'go through each relation
    For Each oRelation In Rel
        sTableName = oRelation.Table
        sForeignTable = oRelation.ForeignTable
        
        sFieldsCount = oRelation.Fields.count
        If sFieldsCount <> 1 Then Stop '>>>>Assumes collection contains only one field if not, you need to reprogram this code
        Set Temp = oRelation.Fields
        sFieldName = Temp.Item(1).Name
        sFieldForeignName = Temp(1).ForeignName
        
        'Search the database for the two cTable objects you wish to cross-reference together
        For k = 0 To UBound(pvTables)
            Set CurrentTable = pvTables(k)
            
            'Find the table in the database that matches sTableName
            If CurrentTable.Name = sTableName Then
                'oTemp1 is one of the cTable
                Set OTemp1 = CurrentTable
                oTemp1Index = k
            End If
            
            'Find sForeignTable
            If CurrentTable.Name = sForeignTable Then
                'oTemp2 is the other cTable
                Set OTemp2 = CurrentTable
                oTemp2Index = k
            End If
        Next k

   '     'Make sure you don't already have OTemp2 listed in OTemp1
   '     'If you are all clear, you may write
   '     OTemp1List = OTemp1.vRelatesTo
   '     If IsEmpty(OTemp1List) Then
   '         bReadOnly1 = False
   '     Else
   '         For n = 0 To UBound(OTemp1List)
   '             If OTemp1List(n).Name = OTemp2.Name Then
   '                 bReadOnly1 = True
   '             End If
   '        Next n
   '    End If
        
   '     'Read the OTemp1 vRelatesTo list, create or append to the list, write it back
   '     If bReadOnly1 <> True Then
   '         If IsEmpty(OTemp1List) Then
   '             OTemp1List = Array(OTemp2)
   '         Else
   '             ReDim Preserve OTemp1List(0 To UBound(OTemp1List) + 1)
   '             Set OTemp1List(UBound(OTemp1List)) = OTemp2
   '         End If
   '
   '         OTemp1.vRelatesTo = OTemp1List
   '         Set pvTables(OTemp1Index) = OTemp1
   '     End If

   '     'Make sure you don't already have OTemp1 listed in OTemp2
   '     'If you are all clear, you may write
   '     OTemp2List = OTemp2.vRelatesTo
   '     If IsEmpty(OTemp2List) Then
   '         bReadOnly2 = False
   '     Else
   '         For m = 0 To UBound(OTemp2List)
   '             If OTemp2List(m).Name = OTemp1.Name Then
   '                 bReadOnly2 = True
   '             End If
   '         Next m
   '     End If

   '     'Read the vRelatesTo list, create or append to the list, write it back
   '     If bReadOnly2 <> True Then
   '         If IsEmpty(OTemp2List) Then
   '             OTemp2List = Array(OTemp1)
   '         Else
   '             ReDim Preserve OTemp2List(0 To UBound(OTemp2List) + 1)
   '             Set OTemp2List(UBound(OTemp2List)) = OTemp1
   '         End If
   '
   '         OTemp2.vRelatesTo = OTemp2List
   '         Set pvTables(OTemp2Index) = OTemp2
   '     End If
   '
   '     'Reset
   '     bReadOnly1 = False
   '
   '     '------------------
   '     'at this point we will not link the two fields
        
        'Search the two cTables for the two cField objects you wish to cross-reference together
        For x = 0 To UBound(OTemp1.vFields)
            Set CurrentField1 = OTemp1.vFields
            Set CurrentField2 = OTemp2.vFields
            
            If CurrentField1.Name = sFieldName Then
                Set oField1 = CurrentField1
                OTemp1FieldIndex = x
            End If
            
            If CurrentField2.Name = sFieldName Then
                Set oField2 = CurrentField2
                OTemp2FieldIndex = x
            End If
            
            If CurrentField1.Name = sFieldForeignName Then
                Set oField1 = CurrentField1
                OTemp1FieldIndex = x
            End If
            
            If CurrentField2.Name = sFieldForeignName Then
                Set oField2 = CurrentField2
                OTemp2FieldIndex = x
            End If
        Next x
        
        'Make sure you don't already have OField2 listed in OField1
        'If you are all clear, you may write
        oTemp1FieldList = oField1.vRelatesTo
        If IsEmpty(oTemp1FieldList) Then
            bReadOnly1 = False
        Else
            For n = 0 To UBound(oTemp1FieldList)
                If oTemp1FieldList(n).Name = oField2.Name Then
                    bReadOnly1 = True
                End If
            Next n
        End If
        
        'Read the oField1 vRelatesTo list, create or append to the list, write it back
        If bReadOnly1 <> True Then
            If IsEmpty(oTemp1FieldList) Then
                oTemp1FieldList = Array(oField2)
            Else
                ReDim Preserve oTemp1FieldList(0 To UBound(oTemp1FieldList) + 1)
                Set oTemp1FieldList(UBound(oTemp1FieldList)) = oField2
            End If
            
            oField1.vRelatesTo = oTemp1FieldList
            Set pvTables(oTemp1Index) = oField1
        End If

        'Make sure you don't already have OField1 listed in OField2
        'If you are all clear, you may write
        oTemp2List = oField2.vRelatesTo
        If IsEmpty(oTemp2List) Then
            bReadOnly2 = False
        Else
            For m = 0 To UBound(oTemp2List)
                If oTemp2List(m).Name = oField1.Name Then
                    bReadOnly2 = True
                End If
            Next m
        End If

        'Read the vRelatesTo list, create or append to the list, write it back
        If bReadOnly2 <> True Then
            If IsEmpty(oTemp2List) Then
                oTemp2List = Array(oField1)
            Else
                ReDim Preserve oTemp2List(0 To UBound(oTemp2List) + 1)
                Set oTemp2List(UBound(oTemp2List)) = oField1
            End If
            
            oField2.vRelatesTo = oTemp2List
            Set pvTables(oTemp2Index) = oField2
        End If
        
        'Reset
        bReadOnly1 = False
        
        
        
    Next oRelation
End Sub


