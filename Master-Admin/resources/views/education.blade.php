@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-user-group"></i> Daftar Edukasi</h3></div>
    <div class="col text-end"><a href="#" data-bs-toggle="modal" data-bs-target="#addEdu"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-plus"></i> Tambah Content</button></a></div>
</div>
<hr>
<div class="row">
    <div class="col">
        <table class="table text-center">
            <div class="row">
                <div class="col text-center"><h3>Buku</h3></div>
            </div>
            <thead>
                <th scope="col">ID</th>
                <th scope="col">Judul</th>
                <th scope="col">Kategori</th>
                <th scope="col">Aksi</th>
            </thead>
            <tbody class="table-group-divider">
                @foreach ($buku as $item)
                <tr>
                    <td>{{ $item->id }}</td>            
                    <td>{{ $item->judul }}</td>            
                    <td>@switch($item->kategori)
                        @case(0)
                        Anak-Anak
                        @break
                        @case(1)
                        Dewasa
                        @break
                        @case(2)
                        Orang Tua   
                        @break
                        @endswitch</td>            
                    <td>
                        <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                            <a href="#" data-bs-toggle="modal" data-bs-target="#infoEdu-{{ $item->id }}"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                            <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Buku"><i class="fa-solid fa-trash"></i></button></a>
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    <div class="col">
        <table class="table text-center">
            <div class="row">
                <div class="col text-center"><h3>Video</h3></div>
            </div>
            <thead>
                <th scope="col">ID</th>
                <th scope="col">Judul</th>
                <th scope="col">Kategori</th>
                <th scope="col">Aksi</th>
            </thead>
            <tbody class="table-group-divider">
                @foreach ($video as $item)
                <tr>
                    <td>{{ $item->id }}</td>            
                    <td>{{ $item->judul }}</td>            
                    <td>@switch($item->kategori)
                        @case(0)
                        Anak-Anak
                        @break
                        @case(1)
                        Dewasa
                        @break
                        @case(2)
                        Orang Tua   
                        @break
                        @endswitch</td> 
                    <td>
                        <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                            <a href="#" data-bs-toggle="modal" data-bs-target="#infoEdu-{{ $item->id }}"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                            <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Video"><i class="fa-solid fa-trash"></i></button></a>
                        </div>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
{{-- Modal Details --}}
@foreach ($data as $item)
<div class="modal fade" id="infoEdu-{{ $item->id }}" tabindex="-1" aria-labelledby="infoEduLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="infoEduLabel">Detail Informasi</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="col text-center mt-2">
                <img src="https://github.com/mdo.png" alt="Foto Profil" width="150">
            </div>
            <div class="col text-center">
                {{ $item->deskripsi }}
            </div>
            <div class="row">
                <div class="col">
                    <table class="table text-center">
                        <thead>
                        </thead>
                        <tbody>
                            <tr>
                                <th scope="row">ID</th>
                                <td>{{ $item->id }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Judul</th>
                                <td>{{ $item->judul }}</td>
                            </tr>
                            <tr>
                                <th scope="row">Kategori</th>
                                <td>@switch($item->kategori)
                                    @case(0)
                                    Anak-Anak
                                    @break
                                    @case(1)
                                    Dewasa
                                    @break
                                    @case(2)
                                    Orang Tua   
                                    @break
                                    @endswitch
                                </td>
                            </tr>
                            <tr>
                                <th scope="row">Content</th>
                                <td>{{ ($item->jenis_education_id === 1) ? 'Buku ' : 'Video' }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endforeach 
{{-- Modal Tambah Banner --}}
<div class="modal fade" id="addEdu" tabindex="-1" aria-labelledby="addEduLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="addEduLabel">Tambah Content Edukasi</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <form>
                <div class="mb-3">
                  <label for="InputEmail1" class="form-label">Email address</label>
                  <input type="email" class="form-control" id="InputEmail1" aria-describedby="emailHelp">
                </div>
                <div class="mb-3">
                  <label for="InputName1" class="form-label">Nama</label>
                  <input type="text" class="form-control" id="InputName1" aria-describedby="nameHelp">
                </div>
                <div class="mb-3">
                  <label for="InputHP1" class="form-label">No. HP</label>
                  <input type="text" class="form-control" id="InputHP1" aria-describedby="HPHelp">
                </div>
                <div class="mb-3">
                    <label for="formFile" class="form-label">Foto Profil</label>
                    <input class="form-control" type="file" id="formFile">
                  </div>
                <div class="mb-3">
                  <label for="InputPassword1" class="form-label">Password</label>
                  <input type="password" class="form-control" id="InputPassword1">
                </div>
                <button type="submit" class="btn btn-primary">Submit</button>
              </form>
        </div>
      </div>
    </div>
</div>
@endsection