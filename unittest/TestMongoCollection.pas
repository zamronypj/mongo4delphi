unit TestMongoCollection;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BaseTestCaseMongo, Mongo;

type
  //Require mongodb service running
  TTestMongoCollection = class(TBaseTestCaseMongo)
  private
  published
    procedure InsertBSONObjectID;
    procedure InsertBSONObjectSimpleTypes;
    procedure InsertBSONObjectWithEmbeddedObject;
    procedure InsertBSONArraySimpleTypes;
    procedure InsertBSONArrayObject;
    procedure InsertBSONArrayWithEmbeddedArrays;
    procedure InsertBSONObjectUUID;
    procedure InsertBSONBinary;
    procedure InsertBSONOldBinary;
    procedure InsertBSONRegEx;
    procedure FindOne;
    procedure TestCount;
    procedure TestCreateCollection;
    procedure TestGetIndexInfo;
    procedure TestDropIndexes;
  end;

implementation

uses Variants, SysUtils, Math, BSONTypes, MongoUtils, BSON;

{ TTestMongoCollection }

procedure TTestMongoCollection.InsertBSONArrayObject;
var
  vBSON: IBSONObject;
  vArray: IBSONArray;
begin
  vArray := TBSONArray.Create;
  vArray.Put(TBSONObject.NewFrom('name', 'Fabricio'));

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  DefaultCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONArraySimpleTypes;
var
  vBSON: IBSONObject;
  vArray: IBSONArray;
begin
  vArray := TBSONArray.Create;
  vArray.Put('123');
  vArray.Put(123);
  vArray.Put(1.23);

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  DefaultCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONArrayWithEmbeddedArrays;
var
  vBSON: IBSONObject;
  vArray: IBSONArray;
begin
  vArray := TBSONArray.NewFrom(TBSONArray.NewFrom(TBSONArray.NewFrom(TBSONObject.NewFrom('name', 'Fabricio'))));

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vArray);

  DefaultCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONObjectSimpleTypes;
var
  vSingle: Single;
  vDouble: Double;
  vCurrency: Currency;
  vLongWord: LongWord;
  vBSON: IBSONObject;
begin
  vSingle := 1.21;
  vDouble := 1.22;
  vCurrency := 1.23;
  vLongWord := High(LongWord) div 2; 

  vBSON := TBSONObject.Create;

  vBSON.Put('id01', 'Fabricio');
  vBSON.Put('id02', Null);
  vBSON.Put('id03', Unassigned);
  vBSON.Put('id04', Date);
  vBSON.Put('id05', Now);
  vBSON.Put('id06', High(Byte));
  vBSON.Put('id07', High(SmallInt));
  vBSON.Put('id08', High(Integer));
  vBSON.Put('id09', High(ShortInt));
  vBSON.Put('id10', High(Word));
  vBSON.Put('id11', vLongWord);
  vBSON.Put('id12', High(Int64));
  vBSON.Put('id13', vSingle);
  vBSON.Put('id14', vDouble);
  vBSON.Put('id15', vCurrency);
  vBSON.Put('id16', True);
  vBSON.Put('id17', False);

  DefaultCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONObjectWithEmbeddedObject;
var
  vBSON,
  vEmbedded: IBSONObject;
begin
  vEmbedded := TBSONObject.Create;
  vEmbedded.Put('id2', '123'); 

  vBSON := TBSONObject.Create;
  vBSON.Put('id', 123);
  vBSON.Put('id2', vEmbedded);

  DefaultCollection.Insert(vBSON);
end;

procedure TTestMongoCollection.InsertBSONObjectID;
begin
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 123).Put('_id', TBSONObjectId.NewFrom));
end;

procedure TTestMongoCollection.InsertBSONObjectUUID;
var
  vGUID: TGUID;
begin
  vGUID := TGUIDUtils.NewGuid;

  DefaultCollection.Insert(TBSONObject.NewFrom('uid', GUIDToString(vGUID)));
end;

procedure TTestMongoCollection.FindOne;
var
  vDoc: IBSONObject;
begin
  DefaultCollection.Insert(TBSONObject.NewFrom('_id', TBSONObjectId.NewFromOID('4f46b9fa65760489cc96ab49')).Put('id', 123));

//  DefaultCollection.Insert(TBSONObject.NewFrom('id', 123).Put('items', TBSONArray.NewFromValues([1, 2, 3])));

  vDoc := DefaultCollection.FindOne(nil);

  CheckNotNull(vDoc);
  CheckEquals(2, vDoc.Count);
  CheckEquals('_id', vDoc[0].Name);
  CheckEquals('ObjectId("4f46b9fa65760489cc96ab49")', vDoc[0].AsObjectId.ToStringMongo);
  CheckEquals('id', vDoc[1].Name);
  CheckEquals(123, Integer(vDoc[1].Value));
end;

procedure TTestMongoCollection.TestCount;
const
  LIMIT = 2;
begin
  CheckEquals(0, DefaultCollection.Count);
  
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 1));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 2));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 3));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 4));
  DefaultCollection.Insert(TBSONObject.NewFrom('id', 5));

  CheckEquals(5, DefaultCollection.Count);
  CheckEquals(LIMIT, DefaultCollection.Count(LIMIT));
  CheckEquals(1, DefaultCollection.Count(TBSONObject.NewFrom('id', 3)));
end;

procedure TTestMongoCollection.TestCreateCollection;
var
  vCollections: IBSONObject;
  vColl: TMongoCollection;
begin
  vCollections := DB.GetUserCollections;
  CheckEquals(0, vCollections.Count);

  vColl := DB.CreateCollection(sColl, TBSONObject.Empty);
  CheckEquals(sColl, vColl.CollectionName);

  vCollections := DB.GetUserCollections;
  CheckEquals(0, vCollections.Count);

  vColl := DB.CreateCollection(sColl, TBSONObject.NewFrom('capped', True).Put('size', 100000));
  CheckEquals(sColl, vColl.CollectionName);

  vCollections := DB.GetUserCollections;
  CheckEquals(1, vCollections.Count);
  CheckEquals(sColl, vCollections.Items['name'].AsString);
end;

procedure TTestMongoCollection.TestDropIndexes;
var
  vIndexes: IBSONArray;
begin
  vIndexes := DefaultCollection.GetIndexInfo;
  CheckNotNull(vIndexes);
  CheckEquals(0, vIndexes.Count);

  DefaultCollection.CreateIndex(TBSONObject.NewFrom('id', 1), 'idx_test');

  vIndexes := DefaultCollection.GetIndexInfo;
  CheckNotNull(vIndexes);
  CheckEquals(2, vIndexes.Count); //One more to _id

  DefaultCollection.DropIndexes;
  
  vIndexes := DefaultCollection.GetIndexInfo;
  CheckNotNull(vIndexes);
  CheckEquals(1, vIndexes.Count); //Index for _id is not deleted  
end;

procedure TTestMongoCollection.TestGetIndexInfo;
var
  vIndexes: IBSONArray;
begin
  vIndexes := DefaultCollection.GetIndexInfo;
  CheckNotNull(vIndexes);
  CheckEquals(0, vIndexes.Count);

  DefaultCollection.CreateIndex(TBSONObject.NewFrom('id', 1), 'idx_test');

  vIndexes := DefaultCollection.GetIndexInfo;
  CheckNotNull(vIndexes);
  CheckEquals(2, vIndexes.Count);

  CheckEquals('idx_test', vIndexes[1].AsBSONObject.Items['name'].AsString);
end;

procedure TTestMongoCollection.InsertBSONBinary;

begin
  DefaultCollection.Insert(TBSONObject.NewFrom('img', TBSONBinary.NewFromFile('resource\image.gif'))).getLastError.RaiseOnError;
end;

procedure TTestMongoCollection.InsertBSONOldBinary;
begin
  DefaultCollection.Insert(TBSONObject.NewFrom('img', TBSONBinary.NewFromFile('resource\image.gif', BSON_SUBTYPE_OLD_BINARY))).getLastError.RaiseOnError;
end;

procedure TTestMongoCollection.InsertBSONRegEx;
var
  vRegEx: IBSONRegEx;
begin
  vRegEx := TBSONRegEx.Create;
  vRegEx.Pattern := 'acme.*corp';
  vRegEx.CaseInsensitive_I := True;
  vRegEx.Multiline_M := True;
  vRegEx.Verbose_X := True;
  vRegEx.DotAll_S := True;
  vRegEx.LocaleDependent_L := True;
  vRegEx.Unicode_U := True;

  DefaultCollection.Insert(TBSONObject.NewFrom('reg', vRegEx));
end;

initialization
  TTestMongoCollection.RegisterTest;

end.
