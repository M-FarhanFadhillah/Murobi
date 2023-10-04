@extends('layouts.tempNav')
@section('container')
<div class="row">
    <div class="col-6 .col-sm-4"><h3><i class="fa-solid fa-user-group"></i> Daftar Edukasi</h3></div>
</div>
<hr>
<div class="row">
    <div class="col">
        <table class="table text-center">
            <div class="row">
                <div class="col"><h3>Buku</h3></div>
                <div class="col-sm-6 .col-sm-8 text-end"><a href="#"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-book"></i> Tambah Buku</button></a></div>
            </div>
            <thead>
                <th scope="col">No</th>
                <th scope="col">ID</th>
                <th scope="col">Judul</th>
                <th scope="col">Kategori</th>
                <th scope="col">Aksi</th>
            </thead>
            <tbody class="table-group-divider">
                <tr>
                    <td>1</td>
                    <td>2057051017</td>            
                    <td>Syahril Fajri Pratama</td>
                    <td>Anak-Anak</td>
                    <td>
                        <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                            <a href="#"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                            <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Buku"><i class="fa-solid fa-trash"></i></button></a>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="col">
        <table class="table text-center">
            <div class="row">
                <div class="col"><h3>Video</h3></div>
                <div class="col-sm-6 .col-sm-8 text-end"><a href="#"><button type="button" class="btn btn-outline-warning"><i class="fa-solid fa-video"></i> Tambah Video</button></a></div>
            </div>
            <thead>
                <th scope="col">No</th>
                <th scope="col">ID</th>
                <th scope="col">Judul</th>
                <th scope="col">Kategori</th>
                <th scope="col">Aksi</th>
            </thead>
            <tbody class="table-group-divider">
                <tr>
                    <td>1</td>
                    <td>2057051017</td>
                    <td>Syahril Fajri Pratama</td>
                    <td>Anak-Anak</td>
                    <td>
                        <div class="btn-group btn-group-sm" role="group" aria-label="Small button group">
                            <a href="#"><button type="button" class="btn btn-outline-info" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Tampilkan Detail Informasi"><i class="fa-solid fa-info"></i></button></a>
                            <a href="#"><button type="button" class="btn btn-outline-danger" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-custom-class="custom-tooltip" data-bs-title="Hapus Video"><i class="fa-solid fa-trash"></i></button></a>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

</div>  
@endsection