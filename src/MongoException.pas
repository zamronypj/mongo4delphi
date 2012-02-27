{***************************************************************************}
{                                                                           }
{                    Mongo Delphi Driver                                    }
{                                                                           }
{           Copyright (c) 2012 Fabricio Colombo                             }
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit MongoException;

interface

uses SysUtils;

type
  EMongoException = class(Exception)
  private
    FCode: Integer;
  public
    property Code: Integer read FCode;

    constructor Create(ACode: Integer; const Msg: string);overload;
    constructor Create(const Msg: string);overload;
  end;

  EIllegalArgumentException = class(EMongoException);
  EMongoConnectionFailureException = class(EMongoException);
  EMongoBufferIsNotConfigured = class(EMongoException);
  EBSONDuplicateKeyInList = class(EMongoException);
  EBSONCannotChangeDuplicateAction = class(EMongoException);

  EMongoDBCursorException = class(EMongoException);
  EMongoDBCursorStateException = class(EMongoDBCursorException);

  ECommandFailure = class(EMongoException);
 
  EMongoDuplicateKey = class(EMongoException);

  EMongoProviderException = class(EMongoException);
  EMongoInvalidResponse = class(EMongoProviderException);
  EMongoReponseAborted = class(EMongoProviderException);


resourcestring
  sInvalidVariantValueType = 'Can''t serialize type "%s".';
  sMongoConnectionFailureException = 'failed to connect to "%s:%d"';
  sMongoBufferIsNotConfigured = 'Buffer is not configured for "%s".';
  sBSONDuplicateKeyInList = 'Key "%s" already exist.';
  sBSONCannotChangeDuplicateAction = 'Cannot change duplicate action after items added ';
  sMongoDBCursorStateException = 'Cannot change state after open query.';

  sMongoInvalidResponse = 'Invalid response for requestId "%d".';
  sMongoReponseAborted = 'Response aborted for requestId "%d".';

implementation

{ EMongoException }

constructor EMongoException.Create(ACode: Integer; const Msg: string);
begin
  inherited Create(Msg);
  FCode := ACode;
end;

constructor EMongoException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

end.
